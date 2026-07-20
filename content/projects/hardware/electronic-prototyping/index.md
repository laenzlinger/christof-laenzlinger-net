---
Title: Electronic Prototyping
description: "DIY SMD assembly setup with Lumen-PNP pick-and-place machine, reflow oven, and automated KiCad-to-OpenPnP workflow."
Tags: [electronics]
cover:
  image: "lumen-pnp.jpeg"
  relative: true
---

My electronic prototyping setup for SMD assembly:

- [Lumen-PNP](https://www.opulo.io/products/lumenpnp) pick-and-place machine
- [Reflow Oven](/projects/hardware/reflow-oven/) — converted toaster oven for solder reflow
- Stencil frame for solder paste application (testing — previously using a 3D-printed holder with taped-down stencils)
- [InvenTree](https://inventree.org/) for parts inventory management

<!--more-->

All my PCBs are assembled with this setup using a similar workflow:
KiCad design → PCB fabrication → stencil & reflow → pick-and-place for remaining components.

The handoff between KiCad and the pick-and-place machine is automated with
[openpnp-tools](/projects/software/openpnp-tools/).

Planned next upgrade: additional feeders to reduce manual tape handling during placement.
