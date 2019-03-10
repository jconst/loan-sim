import UIKit

/// This is a script to compare different mortgage options by simulating payments over time.
/// Specifically, it considers opportunity costs, and allows for putting <20% down initially
/// to get a better rate, and then "recast" after the first year (pay a lump sum to bring LTV
/// ratio down to 80%) to remove PMI.

/// It assumes a fixed-rate, and assumes that you will request PMI be removed at 80% LTV, rather
/// than waiting for it to be automatically removed at 78% LTV.
/// It also ignores home-owners insurance and property taxes, since these will not vary for
/// different mortgage options.

/// Any value until the "Do not modify" line can & should be tweaked to fit the options you are considering.

let purchasePrice: Double = 273_000
let opCostRate = 0.022 // e.g. 2.2% for Ally savings interest, ~6% for S&P 500 index average case
let pmiRate = 0.005

let loans: [Loan] = [
  Loan(
    name: "Better, 10% down, no pts, no recast",
    fractionDown: 0.1,
    interestRate: 0.04375,
    origFees: 0,
    payOffPMIAfter1Year: false,
    recastFee: 0,
    years: 30
  ),
  Loan(
    name: "Better, 10% down, no pts",
    fractionDown: 0.1,
    interestRate: 0.04375,
    origFees: 0,
    payOffPMIAfter1Year: true,
    recastFee: 0,
    years: 30
  ),
  Loan(
    name: "US Bank, 10% down, no pts",
    fractionDown: 0.1,
    interestRate: 0.04375,
    origFees: 500,
    payOffPMIAfter1Year: true,
    recastFee: 250,
    years: 30
  ),
  Loan(
    name: "Better, 20% down, no pts",
    fractionDown: 0.2,
    interestRate: 0.045,
    origFees: 0,
    payOffPMIAfter1Year: false,
    recastFee: 0,
    years: 30
  )
]

// Do not modify below this line (unless you intend to change/extend the algorithm)
// --------------------------------------------------------------------------------

struct Loan {
  let name: String
  let fractionDown: Double
  let interestRate: Double
  let origFees: Double
  let payOffPMIAfter1Year: Bool
  let recastFee: Double
  let years: Int
}

for loan in loans {
  print("loan '\(loan.name)':")

  let downPayment = purchasePrice * loan.fractionDown
  var principal = purchasePrice - downPayment
  let cashToClose = downPayment + loan.origFees
  let monthlyRate = loan.interestRate / 12
  var rate = monthlyRate
  let yearlyPMI = (loan.fractionDown < 0.2) ? pmiRate * principal : 0
  var monthlyPMI = yearlyPMI / 12

  let numPayments = Double(12 * loan.years)

  var baseMonthlyPayment = calcMonthlyPayment(rate, principal, numPayments)
  var monthlyPayment = baseMonthlyPayment + monthlyPMI

  if monthlyPMI > 0 {
    print("  monthly PMI: \(toCash(monthlyPMI))")
    print("  monthly payment with PMI: \(toCash(monthlyPayment))")
  }

  var amountPaid = cashToClose
  var opCostAmountGained = cashToClose
  var monthlyOpCostMult: Double = 1 + (opCostRate / 12)
  var nonPrincPaid: Double = 0

  for year in 0..<loan.years {
    for month in 0..<12 {

      amountPaid += monthlyPayment
      opCostAmountGained = (opCostAmountGained + monthlyPayment) * monthlyOpCostMult

      let interestDue = principal * rate
      nonPrincPaid += interestDue + monthlyPMI
      let principalPaid = baseMonthlyPayment - interestDue
      assert(principalPaid > 0)
      principal -= principalPaid

      if !loan.payOffPMIAfter1Year && monthlyPMI > 0 && principal < (purchasePrice * 0.8) {
        print("  paid off PMI at year \(year), month \(month) (0-indexed)")
        monthlyPayment = baseMonthlyPayment
        monthlyPMI = 0
      }
    }

    if year == 0 && loan.payOffPMIAfter1Year {
      rate = loan.interestRate / 12
      let lumpSum = principal - (purchasePrice * 0.8)
      principal = purchasePrice * 0.8
      opCostAmountGained += lumpSum + loan.recastFee
      amountPaid += lumpSum + loan.recastFee
      monthlyPayment = calcMonthlyPayment(rate, principal, Double(loan.years - 1) * 12)

      print("  lump sum payment for recast: \(toCash(lumpSum))")
    }
  }

  print("  monthly payment: \(toCash(monthlyPayment))")
  print("  total $ paid: \(toCash(amountPaid))")
  print("  total interest + fees paid: \(toCash(nonPrincPaid))")
  print("  total paid + op cost: \(toCash(opCostAmountGained))")
  print("")
}

func calcMonthlyPayment(_ rate: Double, _ principal: Double, _ numPayments: Double) -> Double {
  return (rate * principal) / (1 - pow(1 + rate, -numPayments))
}

func toCash(_ n: Double) -> String {
  let formatter = NumberFormatter()
  formatter.locale = Locale.current
  formatter.numberStyle = .currency
  return formatter.string(from: n as NSNumber)!
}
