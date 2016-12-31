# VisualPlaceRecognition
Visual Place Recognition Project : School project for the course [Object recognition and computer vision](http://www.di.ens.fr/willow/teaching/recvis16) @ ENS

### Overview

**Sense of Place** is a feeling or perception held by people about a location: some characteristics of a place can
be perceived at first sight, such as wealth or safety. Lately, there has been recent interest in predicting these
human judgments with computer vision techniques [Ordonez and Berg 2014].

The **CNN architecture with the NetVLAD** layer from [Arandjelović et al. 2016] significantly outperforms
non-learnt image representations as well as off-the-shelf CNN descriptors, and improves over the state-of-the-
art on challenging image retrieval benchmarks. The goal of this project is to transfer the CNN representation
learnt for Visual Place Recognition to predict human judgments of safety and wealth of locations.

More details about the project can be found [here](https://github.com/Rachine/VisualPlaceRecognition/blob/master/FP_Nadjahi_Riad.pdf).

The original Project about Visual Place recoginition can be found [here](http://www.di.ens.fr/willow/research/netvlad/).

### Authors
- Kimia Nadjahi
- [Rachid Riad](https://rachine.github.io/)


### References
[Arandjelović et al. 2016] Arandjelović, R., Gronat, P., Torii, A., Pajdla, T., and Sivic, J. (2016). NetVLAD:
CNN architecture for weakly supervised place recognition. In IEEE Conference on Computer Vision and Pattern Recognition.

[Ordonez and Berg 2014] Ordonez, V. and Berg, T. (2014). Learning high-level judgments of urban perception,
volume 8694 LNCS of Lecture Notes in Computer Science (including subseries Lecture Notes in Artificial
Intelligence and Lecture Notes in Bioinformatics), pages 494–510. Springer Verlag, Germany, part 6 edition.

[A. Vedaldi and K. Lenc 2015 ] A. Vedaldi and K. Lenc (2015). MatConvNet -- Convolutional Neural Networks for MATLAB. Proceeding of the ACM Int. Conf. on Multimedia

### Acknowledgments
A huge part of the code is taken from this [github repository](https://github.com/Relja/netvlad) and the examples in MatConvNet
