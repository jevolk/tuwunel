## Overview

We define a release pipeline `Main` (main.yml) and its subroutines defined in the other yamls. These 
form a high-level control specification to drive the authoritative self-hosted build system in 
`/docker`. In other words, this is a sort of terminal, a "thin-client" with a display and a keyboard 
for our docker mainframe. We minimize vendor-lockin and duplication with other frameworks by limiting 
everything here to only what is essential for driving the docker builder, which can be self-hosted and 
operated offline or with other services like gitlab or forgejo with minimal duplication.

Importantly, we slightly relax the above by specifying details of the actual CI pipeline, specifically the 
control-flow logic to go from some input event to some output or release, here. This gives us better integration 
with github, like granular progress indications by breaking up operations as individual jobs and workflows 
within the pipeline. This means we'll have duplicate logic with other services, but only as it relates to 
high-level control flow.

We specify this CI/CD pipeline in the form of a single, unified, traditional program. There is a
main function with a single control flow. It takes inputs, produces outputs and artifacts, and is
invoked by various events or manually, it can even parallelize as necessary rather than being limited
by its linearity -- the point is that everything passes through it no matter how it gets there or
where it leads. This might depart from typical github actions which are loose patchwork of independent
things going on all over the place.
