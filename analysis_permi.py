###
import eli5
from eli5.sklearn import PermutationImportance
from sklearn.svm import SVC
from sklearn.linear_model import LogisticRegression
from sklearn.naive_bayes import BernoulliNB
import pandas as pd
import numpy as np
import matplotlib
import matplotlib.pyplot as plt
import seaborn as sns

###
OUTPUTDIR = './output/analysis/Stage2/PermutationImportance/'
statinfofile = "./output/analysis/Stage2/featurestat_20sec.csv"
T = pd.read_csv(statinfofile)
N = len(T['groupid'].unique())
K = round(N/10)
M = 1024

###
idx = (T['type'] == "song") | (T['type'] == "desc")
TT = T[idx]
featureset = T['feature'].unique()

X = np.zeros((N*2, len(featureset)))
y = np.zeros((N*2, 1))
for i in range(N):
    TT_i = TT[TT['groupid'] == (i + 1)]

    for j in range(len(featureset)):
        TT_ij = TT_i[TT_i['feature'] == featureset[j]]
        X[i, j] = TT_ij[TT_ij['type'] == 'song']['mean']
        X[i + N, j] = TT_ij[TT_ij['type'] == 'desc']['mean']
        y[i, 0] = 0
        y[i + N, 0] = 1

## Check correlation
idx = y[:, 0] == 0
Z = X[idx, :]
C = np.corrcoef(Z.T)
np.savetxt(OUTPUTDIR + 'Correlationmat_song.csv', C, delimiter=",")

idx = y[:, 0] == 1
Z = X[idx, :]
C = np.corrcoef(Z.T)
np.savetxt(OUTPUTDIR + 'Correlationmat_desc.csv', C, delimiter=",")

##
nummodel = 3

permi_score = np.zeros((len(featureset), M, nummodel))
dummyfeaturename = ('x0', 'x1', 'x2', 'x3', 'x4', 'x5', 'x6', 'x7', 'x8', 'x9', 'x10', 'x11', 'x12')

classificationscore = np.zeros((M, nummodel))
permi_prec = np.zeros((M, 2, nummodel))
permi_rcal = np.zeros((M, 2, nummodel))

classificationresult = np.zeros((N*2, M, nummodel)) + np.nan

# normalization
for i in range(len(featureset)):
    X[:, i] = (X[:, i] - np.mean(X[:, i]))/np.std(X[:, i])

for m in range(M):
    idx_heldout = np.random.choice(N, K, replace = False)
    idx = np.zeros(N*2)
    idx[idx_heldout] = 1
    idx[(idx_heldout + N)] = 1

    svc = SVC(C=1.0, kernel='rbf', gamma='scale').fit(X[idx == 0, :], y[idx == 0, 0])
    lrm = LogisticRegression(penalty='l2', C=1.0, fit_intercept=True).fit(X[idx == 0, :], y[idx == 0, 0])
    bnb = BernoulliNB(alpha=1.0, binarize=0.0, fit_prior=True, class_prior=None).fit(X[idx == 0, :], y[idx == 0, 0])

    perm = PermutationImportance(svc, n_iter = 20).fit(X[idx == 1, :], y[idx == 1, 0])
    permi_score_svm = eli5.explain_weights_df(perm)
    perm = PermutationImportance(lrm, n_iter=20).fit(X[idx == 1, :], y[idx == 1, 0])
    permi_score_lrm = eli5.explain_weights_df(perm)
    perm = PermutationImportance(bnb, n_iter=20).fit(X[idx == 1, :], y[idx == 1, 0])
    permi_score_bnb = eli5.explain_weights_df(perm)

    y_test = y[idx == 1, 0]
    prdct_svm = svc.predict(X[idx == 1, :])
    prdct_lrm = lrm.predict(X[idx == 1, :])
    prdct_bnb = bnb.predict(X[idx == 1, :])
    score_svm = prdct_svm == y_test
    score_lrm = prdct_lrm == y_test
    score_bnb = prdct_bnb == y_test

    classificationscore[m, 0] = np.mean(score_svm)
    classificationscore[m, 1] = np.mean(score_lrm)
    classificationscore[m, 2] = np.mean(score_bnb)

    permi_prec[m, 0, 0] = np.mean(score_svm[prdct_svm == 0])
    permi_prec[m, 1, 0] = np.mean(score_svm[prdct_svm == 1])
    permi_prec[m, 0, 1] = np.mean(score_lrm[prdct_lrm == 0])
    permi_prec[m, 1, 1] = np.mean(score_lrm[prdct_lrm == 1])
    permi_prec[m, 0, 2] = np.mean(score_bnb[prdct_bnb == 0])
    permi_prec[m, 1, 2] = np.mean(score_bnb[prdct_bnb == 1])

    permi_rcal[m, 0, 0] = np.mean(score_svm[y_test == 0])
    permi_rcal[m, 1, 0] = np.mean(score_svm[y_test == 1])
    permi_rcal[m, 0, 1] = np.mean(score_lrm[y_test == 0])
    permi_rcal[m, 1, 1] = np.mean(score_lrm[y_test == 1])
    permi_rcal[m, 0, 2] = np.mean(score_bnb[y_test == 0])
    permi_rcal[m, 1, 2] = np.mean(score_bnb[y_test == 1])

    classificationresult[idx == 1, m, 0] = (score_svm - 1)
    classificationresult[idx == 1, m, 1] = (score_lrm - 1)
    classificationresult[idx == 1, m, 2] = (score_bnb - 1)

    for j in range(len(dummyfeaturename)):
        permi_score[j, m, 0] = permi_score_svm[permi_score_svm['feature'] == dummyfeaturename[j]]['weight']
        permi_score[j, m, 1] = permi_score_lrm[permi_score_lrm['feature'] == dummyfeaturename[j]]['weight']
        permi_score[j, m, 2] = permi_score_bnb[permi_score_bnb['feature'] == dummyfeaturename[j]]['weight']

permi_Fval = (2*permi_prec*permi_rcal)/(permi_prec + permi_rcal)

##
pd.DataFrame(data={'accuracy_svm': np.mean(classificationscore[:, 0]),
                   'accuracy_lrm': np.mean(classificationscore[:, 1]),
                   'accuracy_bnb': np.mean(classificationscore[:, 2]),
                   'precision_song_svm': np.mean(permi_prec[:, 0, 0]),
                   'precision_desc_svm': np.mean(permi_prec[:, 1, 0]),
                   'precision_song_lrm': np.mean(permi_prec[:, 0, 1]),
                   'precision_desc_lrm': np.mean(permi_prec[:, 1, 1]),
                   'precision_song_bnb': np.mean(permi_prec[:, 0, 2]),
                   'precision_desc_bnb': np.mean(permi_prec[:, 1, 2]),
                   'recall_song_svm': np.mean(permi_rcal[:, 0, 0]),
                   'recall_desc_svm': np.mean(permi_rcal[:, 1, 0]),
                   'recall_song_lrm': np.mean(permi_rcal[:, 0, 1]),
                   'recall_desc_lrm': np.mean(permi_rcal[:, 1, 1]),
                   'recall_song_bnb': np.mean(permi_rcal[:, 0, 2]),
                   'recall_desc_bnb': np.mean(permi_rcal[:, 1, 2]),
                   'Fvalue_song_svm': np.mean(permi_Fval[:, 0, 0]),
                   'Fvalue_desc_svm': np.mean(permi_Fval[:, 1, 0]),
                   'Fvalue_song_lrm': np.mean(permi_Fval[:, 0, 1]),
                   'Fvalue_desc_lrm': np.mean(permi_Fval[:, 1, 1]),
                   'Fvalue_song_bnb': np.mean(permi_Fval[:, 0, 2]),
                   'Fvalue_desc_bnb': np.mean(permi_Fval[:, 1, 2])}, index=[0]).to_csv(OUTPUTDIR + 'performance.csv', sep=",", index = False)

##
modelname = ('SVM', 'LRM', 'BNB')
for i in range(nummodel):
    result = pd.DataFrame(data={'feature': featureset, 'pmi': np.mean(permi_score[:, :, i], axis=1)})
    result.to_csv(OUTPUTDIR + 'PermutationImportance_' + modelname[i] + '.csv', sep=",", index=False)

    pd.DataFrame(data={'MeanErrorFreq': np.nanmean(classificationresult[:, :, i], axis=1)}).to_csv(OUTPUTDIR + 'meanfreqerr_' + modelname[i] + '.csv',
                                                                                                   sep = ",", index = False)


print("done")

"""
## Check data
plt.show()
idx = 1

fig = plt.figure()
fig.add_subplot(1, 2, 1)
plt.violinplot([X[y[:, 0] == 0, idx], X[y[:, 0] == 1, idx]])
fig.add_subplot(1, 2, 2)
plt.hist(X[y[:, 0] == 0, idx])
plt.hist(X[y[:, 0] == 1, idx])
"""