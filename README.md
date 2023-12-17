Final Project Submission and Repository:

The VSA Toolbox:

---
The Zip file submitted in Courseworks is likely the easiest and surest way to run and test
the MATLAB implementations. All you need to do is download the Zip, import it into MATLAB,
and run the 'demo_cpu.m' and 'demo_gpu.m' files.

In the 'VSA_Toolbox-master.zip' file you will find all files from the original open-source
implementations, and my original implementations. Files with the TUC license banners are 
originals and have not been altered, any files without those banners have been optimizers
and configured for this assignment. 

For example, none of the original open-source code was performing timing tests on binding, 
bundling, or elapsed time. Similarly, there was no code implementations to run on GPU devices.

The image set that was used for testing is housed under the 'experimental_scripts' folder. It
is the 'GardensPointWalking' image set - generally, I used all of the same datasets found in 
the source paper 'A comparison of Vector Symbolic Architectures' that can be found here:

file:///Users/stephen/Downloads/s10462-021-10110-3%20(6).pdf

---

Code Conversions (C, Python):

---
Code conversions to C and Python have been included in the GitHub repository and are contained
in ipynb notebooks. 'demo_c.ipynb' is for demonstration purposes only, it is meant to demonstrate
how MATLAB VSAs can be converted to the C language. 

'demo_python.ipynb' is operational and is a full conversion of the VSA models tested in the source
paper and our MATLAB demonstrations. 'demo_python.ipynb' has been run and tested, the results and
corresponding code is contained in the notebook. You will need to upload the 'GardensPointWalking'
dataset to your Google Drive (or directly into the notebook) in order to re-run and test the code. 
The python demonstration has a mounted Drive cell at the top of the notebook, so the easiest way to
test the notebook is to import the dataset into your Drive. 

---

VSA Results and Plots:

---
All results for CPU, T4, V100, and A100 runs are included in the notebook 'vsa_results.ipynb'. 
Additionally, this notebook holds all code and plots visualizing our results that have been
included in the final PowerPoint presentation. 

---

VSA Results (txt files):

---
Additionally, results for each run on specific hardware devices are included in the GitHub as
'demo_cpu.txt', 'T4 Results.txt', 'V100 Results.txt', 'A100 Results.txt'.

---
