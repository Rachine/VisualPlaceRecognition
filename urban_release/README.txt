Urban Perception v0.1 release
Vicente Ordonez @ UNC Chapel Hill 2013

- Code for downloading the images in the Place Pulse dataset.
- Code for downloading images from different cities from Google Street View.
- Code for Train/Test Classification of Urban Images.
- Code for Train/Test Regression of Urban Images.
- Code for visualizing predictions on a heatmap overlay.

The code presented here supports the following paper.

Learning High-level Judgements of Urban Perception.
Vicente Ordonez and Tamara L. Berg.
European Conference on Computer Vision (ECCV 2014).

How to run this code and what is included:
1. First you want to download the images from the Place Pulse dataset.
   You need to edit and run the file code/download_place_pulse_urban_data.m
   Make sure you got a copy of the file consolidated_data_jsonformatted.json
   from the Place Pulse project webpage http://pulse.media.mit.edu/data/
   Take into account that this will download the latest available imagery from Google.
   You can send me an email to obtain the 2013 images that I used or the 2011 images
   from the original data collection in the PlacePulse dataset (vicente at cs dot unc dot edu).

2. Edit and run classify_strets.m to replicate the classification experiments from the paper.
   This will also compute features. Make sure you setup the config options to define
   what features you will be using.

3. Edit and run regress_strets.m to replicate the classification experiments from the paper.
   This will also compute features. Make sure you setup the config options to define
   what features you will be using.

4. Run create_streets_heatmaps.m to create heatmaps visualizing the output regression predictions.
   Make sure you configure the variablies in the file for your own setup.
   I'm relying here on the EMat templating library by K.Yamaguchi. (Included in the lib directory).
 
