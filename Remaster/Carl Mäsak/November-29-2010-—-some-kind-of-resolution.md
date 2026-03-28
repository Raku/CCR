# November 29 2010 — some kind of resolution
    
*Originally published on [30 November 2010](http://strangelyconsistent.org/blog/november-29-2010-some-kind-of-resolution) by Carl Mäsak.*

> 63 years ago today, a plan for partitioning Palestine was adopted by the General Assembly of the United Nations.

> The resolution sought to address the conflicting objectives and claims to the Mandate territory of two competing nationalist movements, Zionism (Jewish nationalism) and Arab nationalism, as well as to resolve the plight of Jews displaced as a result of the Holocaust. The resolution called for the withdrawal of British forces and termination of the Mandate by 1 August 1948, and establishment of the new independent states by 1 October 1948. A transitional period under United Nations auspices was to begin with the adoption of the resolution, and lasting until the establishment of the two states. However, war broke out and the partition plan was never implemented by the Security Council.

The comparison between the proposed borders and the armistice lines from two years later looks like [an attempt to beat the 4-color theorem](https://en.wikipedia.org/wiki/File:1947-UN-Partition-Plan-1949-Armistice-Comparison.png).

Today, I handled the tests of Routes, Astaire and Squerl.

- I removed Routes. The last commit on it is from June 2009 and has the message `add comment-question about rakudobug, Routes is broken for now` (by Ilya, who no longer contributes actively to Web.pm). The commit contains debug output, and has no easy fix. Under those conditions, I see no way to get Routes working. Probably best to consider it a work-in-progress that never really got there.
- Astaire had one test file that looked nice but had never run. I skipped it for now.
- Squerl had four failing tests that simply needed `TODO`ing. I also tried implementing them, but ran into unknown (!) problems, something I don't often do nowadays. I got as far in my diagnosing the problem as identifying that it occurred in the boundary between a caller and a callee. Beyond that, I have no idea what's going wrong.

It's rather nice to see the Web.pm test suite run with result `PASS`. Might be the first time it does that, I don't recall.
