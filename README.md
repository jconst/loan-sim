### Loan Simulator Playground

This is a script I made to compare different mortgage options by simulating payments over time.
Specifically, it considers opportunity costs, and allows for putting <20% down initially
to get a better rate, and then "recast" after the first year (pay a lump sum to bring LTV
ratio down to 80%) to remove PMI.

It assumes a fixed-rate, and assumes that you will request PMI be removed at 80% LTV, rather
than waiting for it to be automatically removed at 78% LTV.
It also ignores home-owners insurance and property taxes, since these will not vary for
different mortgage options.

Any value until the "Do not modify" line can & should be tweaked to fit the options you are considering.
The values you see are some example options I'm currently considering for my own mortgage.
