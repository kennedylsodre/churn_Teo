#%%
import pandas as pd 
import sqlalchemy

from sklearn import model_selection
from sklearn.preprocessing import StandardScaler,OneHotEncoder()
from sklearn.compose import ColumnTransformer
from sklearn import ensemble
from sklearn import metrics
from sklearn.pipeline import Pipeline

from feature_engine.encoding import OneHotEncoder
# %%
conn = sqlalchemy.create_engine('sqlite:///../../data/featurestore.db')
# %%
with open('abt.sql','r') as query:
    query = query.read()

df = pd.read_sql_query(query,conn)
# %%
df.head()
# %%
df.info()
# %%
df_oot = df[df['dtRef']== df['dtRef'].max()]
df_train = df[df['dtRef']< df['dtRef'].max()]
# %%
target = 'flChurn'
features = df_train.columns[2:]
features = [i for i in features if i != 'flChurn']
# %%
X_train, X_test,y_train,y_test = model_selection.train_test_split(df_train[features],
                                                                  df_train[target],
                                                                  test_size=0.8,
                                                                  random_state=42,
                                                                  stratify=df_train[target])
# %%
print('Taxa de resposta Train ',y_train.mean())
print('Taxa de resposta Test ',y_test.mean())
# %%
cat_features = X_train.dtypes[X_train.dtypes == 'object'].index.tolist()
num_features = list(set(features)-set(cat_features))
# %%
X_train[cat_features].describe()
# %%
one_hot = OneHotEncoder(variables = cat_features,drop_last= True)
# %%
pre_process= ColumnTransformer([
            ('cat',OneHotEncoder(),cat_features),
            ('num',StandardScaler(),num_features)])
modelo = ensemble.RandomForestClassifier()
model_pipeline = Pipeline(
    [
        ('Pre Porcessamento',pre_process)
        ,('modelo',modelo)
    ]
)
model_pipeline.fit(X_train,y_train)
# %%
y_train_proba = model_pipeline.predict_proba(X_train)
y_test_proba = model_pipeline.predict_proba(X_test)
y_oot_proba = model_pipeline.predict_proba(df_oot[features])
# %%
def report_metrics(y_true, y_proba, cohort=0.5):

    y_pred = (y_proba[:,1]>cohort).astype(int)

    acc = metrics.accuracy_score(y_true, y_pred)
    auc = metrics.roc_auc_score(y_true, y_proba[:,1])
    precision = metrics.precision_score(y_true, y_pred)
    recall = metrics.recall_score(y_true, y_pred)

    res = {
        'Acurárica': acc,
        'Curva Roc': auc,
        "Precisão": precision,
        "Recall": recall,
        }

    return res

report_train = report_metrics(y_train, y_train_proba)
report_train['base'] = 'Train'

report_test = report_metrics(y_test, y_test_proba)
report_test['base'] = 'Test'

report_oot = report_metrics(df_oot[target], y_oot_proba)
report_oot['base'] = 'Oot'

df_metrics = pd.DataFrame([report_train,report_test,report_oot])
print(df_metrics)
# %%
