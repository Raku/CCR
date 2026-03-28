# November 14 2009 — it's a slightly smaller step for a man
    
*Originally published on [14 November 2009](http://strangelyconsistent.org/blog/november-14-2009-its-a-slightly-smaller-step-for-a-man) by Carl Mäsak.*

> 40 years ago today, the second mission to land on the moon, [Apollo 12](https://en.wikipedia.org/wiki/Apollo_12), launched in difficult weather conditions:

Apollo 12 launched on schedule, during a rainstorm. 36.5 seconds after lift-off from Kennedy Space Center, the vehicle triggered a lightning discharge through itself and down to the earth through the [booster] Saturn's ionized plume. Protective circuits on the fuel cells in the service module falsely detected overloads and took all three fuel cells offline, along with much of the CSM instrumentation. A second strike at 52 seconds after launch knocked out the "8-ball" attitude indicator. The telemetry stream at Mission Control was garbled nonsense. However, the Saturn V continued to fly correctly; the strikes had not affected the Saturn V's Instrument Unit.

The loss of all three fuel cells put the CSM entirely on batteries. [...] [EECOM John] Aaron made a call: "Try SCE to aux". This switched the SCE to a backup power supply. The switch was fairly obscure and neither the Flight Director, CAPCOM, nor Commander Conrad immediately recognized it. Lunar module pilot Alan Bean, flying in the right seat as the CSM systems engineer, remembered the SCE switch from a training incident a year earlier when the same failure had been simulated. Aaron's quick thinking and Bean's memory saved what could have been an aborted mission. Bean put the fuel cells back on line, and with telemetry restored, the launch continued successfully. Once in earth parking orbit, the crew carefully checked out their spacecraft before re-igniting the S-IVB third stage for trans-lunar injection. The lightning strikes had caused no serious permanent damage.

I must say this puts things like dead car batteries into perspective.

I started doing more work on the pastebin tonight, but I soon realized that I'm too tired to do delicate work.

Instead, I went hunting the Rakudo source for some small documentation infelicity to fix. I stumbled over the perfect one: [the code said '&&' but the comment said 'or'](https://github.com/rakudo/rakudo/commit/7347ec030170234343a191d80191ae68f846a81d). I fixed that, and this will have to constitute today's work. Baby steps.
