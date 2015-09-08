#!/bin/bash

#convert data
java weka.core.converters.CSVLoader dataTest.csv > dataTest.arff

#classification
java weka.classifiers.meta.OrdinalClassClassifier -t dataTrain.arff -T dataTest.arff -no-cv -W weka.classifiers.functions.LibSVM -- -S 0 -K 2 -C 50 -G 1 -R 1e-9