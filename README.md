# Structure-Preserving Numerical Methods for Two Nonlinear Systems of Dispersive Wave Equations

[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10709026.svg)](https://doi.org/10.5281/zenodo.10709026)


This repository contains information and code to reproduce the results presented in the
article
```bibtex
@article{lampert2025structure,
  title={Structure-preserving numerical methods for two nonlinear systems of
           dispersive wave equations},
  author={Lampert, Joshua and Ranocha, Hendrik},
  journal={Computational Science and Engineering},
  volume={2},
  number={2},
  pages={e70016},
  year={2025},
  month={10},
  doi={10.1007/s44207-025-00006-3},
  eprint={2402.16669},
  eprinttype={arxiv},
  eprintclass={math.NA}
}
```

If you find these results useful, please cite the article mentioned above. If you
use the implementations provided here, please **also** cite this repository as
```bibtex
@misc{lampert2024structureRepro,
  title={Reproducibility repository for
         "{S}tructure-Preserving Numerical Methods
           for Two Nonlinear Systems of Dispersive Wave Equations"},
  author={Lampert, Joshua and Ranocha, Hendrik},
  year={2024},
  howpublished={\url{https://github.com/JoshuaLampert/2024\_dispersive\_shallow\_water}},
  doi={10.5281/zenodo.10709026}
}
```
and [DispersiveShallowWater.jl](https://github.com/JoshuaLampert/DispersiveShallowWater.jl) as
```bibtex
@misc{lampert2023dispersive,
  title={{D}ispersive{S}hallow{W}ater.jl: {S}tructure-preserving numerical
         methods for dispersive shallow water models},
  author={Lampert, Joshua},
  year={2023},
  month={10},
  howpublished={\url{https://github.com/JoshuaLampert/DispersiveShallowWater.jl}},
  doi={10.5281/zenodo.10034636}
}
```

## Abstract

We use the general framework of summation-by-parts operators
to construct conservative, energy-stable, and well-balanced
semidiscretizations of two different nonlinear systems of
dispersive shallow water equations with varying bathymetry:
(i) a variant of the coupled Benjamin-Bona-Mahony (BBM) equations
and (ii) a recently proposed model by Svärd and Kalisch (2025) with
enhanced dispersive behavior. Both models share the property of
being conservative in terms of a nonlinear invariant, often
interpreted as energy. This property is preserved exactly
in our novel semidiscretizations. To obtain fully-discrete
energy-stable schemes, we employ the relaxation method.
Our novel methods generalize energy-conserving
methods for the BBM-BBM system to variable bathymetries. Compared to the
low-order, energy-dissipative finite volume method proposed by Svärd and Kalisch,
our schemes are arbitrary high-order accurate, energy-conservative or -stable,
can deal with periodic and reflecting boundary conditions, and can be any
method within the framework of summation-by-parts operators including
finite difference and finite element schemes.
We present improved numerical properties of our methods in some test cases.



## Numerical experiments

To reproduce the numerical experiments presented in this article, you need
to install [Julia](https://julialang.org/). The numerical experiments presented
in this article were performed using Julia v1.11.2.

First, you need to download this repository, e.g., by cloning it with `git`
or by downloading an archive via the GitHub interface. Then, you need to start
Julia in the `code` directory of this repository and follow the instructions
described in the `README.md` file therein.


## Authors

- Joshua Lampert (University of Hamburg, Germany)
- [Hendrik Ranocha](https://ranocha.de) (Johannes Gutenberg University Mainz, Germany)


## License

The code in this repository is published under the MIT license, see the
`LICENSE` file.


## Disclaimer

Everything is provided as is and without warranty. Use at your own risk!
