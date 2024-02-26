# Structure-Preserving Numerical Methods for Two Nonlinear Systems of Dispersive Wave Equations

[![License: MIT](https://img.shields.io/badge/License-MIT-success.svg)](https://opensource.org/licenses/MIT)
[![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.10709027.svg)](https://doi.org/10.5281/zenodo.10709027)


This repository contains information and code to reproduce the results presented in the
article
```bibtex
@online{lampert2024structure-preserving,
  title={Structure-Preserving Numerical Methods for
         Two Nonlinear Systems of Dispersive Wave Equations},
  author={Lampert, Joshua and Ranocha, Hendrik},
  year={2024},
  month={2},
  doi={TODO},
  eprint={TODO},
  eprinttype={arxiv},
  eprintclass={math.NA}
}
```

If you find these results useful, please cite the article mentioned above. If you
use the implementations provided here, please **also** cite this repository as
```bibtex
@misc{lampert2024structure-preservingRepro,
  title={Reproducibility repository for
         "{S}tructure-Preserving Numerical Methods
           for Two Nonlinear Systems of Dispersive Wave Equations"},
  author={Lampert, Joshua and Ranocha, Hendrik},
  year={2024},
  howpublished={\url{https://github.com/JoshuaLampert/2024_structure-preserving_dispersive_waves}},
  doi={10.5281/zenodo.10709027}
}
```

## Abstract

We use the general framework of summation by parts operators to construct conser-
vative, entropy-stable and well-balanced semidiscretizations of two different nonlinear
systems of dispersive shallow water equations with varying bathymetry: (i) a variant
of the coupled Benjamin-Bona-Mahony (BBM) equations and (ii) a recently proposed
model by Svärd and Kalisch (2023) with enhanced dispersive behavior. Both models
share the property of being conservative in terms of a nonlinear invariant, often inter-
preted as entropy function. This property is preserved exactly in our novel semidis-
cretizations. To obtain fully-discrete entropy-stable schemes, we employ the relaxation
method. We present improved numerical properties of our schemes in some test cases.


## Numerical experiments

To reproduce the numerical experiments presented in this article, you need
to install [Julia](https://julialang.org/). The numerical experiments presented
in this article were performed using Julia v1.10.1.

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
