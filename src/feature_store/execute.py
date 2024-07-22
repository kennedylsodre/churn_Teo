#%%
import pandas as pd 
import sqlalchemy
import datetime
from tqdm import tqdm
from sqlalchemy import exc
import argparse

# %%
def import_query(path):
    with open(path,'r') as query:
        return query.read()
#%%    
def define_dates(date_start=None,date_stop=None):
    #Função criada para definir as datas das safras que serão ingeridas no banco de dados
    #Caso não seja passado nenhum parâmetro especifico para início e fim, as safras se iniciarão 
    #a partir da primeira transação +21 dias até a data de hoje
    if date_start == None:
        conn = sqlalchemy.create_engine('sqlite:///../../data/database.db')
        date_start = pd.read_sql_query('SELECT min(dtTransaction) as dtstart FROM transactions',conn)
        date_start = str(date_start['dtstart'].iloc[0][:10])
        date_start = datetime.datetime.strptime(date_start,'%Y-%m-%d')
        date_start += datetime.timedelta(days=21)
    else:
        date_start = datetime.datetime.strptime(date_start,'%Y-%m-%d')
    if date_stop == None:
        date_stop = datetime.datetime.today()
    else:
        date_stop = datetime.datetime.strptime(date_stop,'%Y-%m-%d')
    dates = []
    while date_start <= date_stop:
        dates.append(date_start.strftime('%Y-%m-%d'))
        date_start += datetime.timedelta(days=1)
    return dates
#%%
def ingest_data(table,query,dates,origin_connection, target_connection):
    print(f'-----------------------Iniciando ingestão da tabela {table}-----------------------  ')
    
    for dt in tqdm(dates):
        with target_connection.connect() as con:
            try:
                state = f"DELETE FROM {table} WHERE dtRef = '{dt}';"       
                con.execute(sqlalchemy.text(state))
                #con.commit()
            except exc.OperationalError as err:
                print("Tabela ainda não existe, criando ela...")

        query_fmt = query.format(date = dt)
        df = pd.read_sql(query_fmt,origin_connection)
        df.to_sql(table,target_connection,index=False,if_exists='append')
       
       
    
 
# %%
parser = argparse.ArgumentParser()
parser.add_argument("--feature_store",'-f',help="Nome da feature store",type=str)
parser.add_argument("--start",'-s',default=None,help='Data de início ingestão',type=str)
parser.add_argument('--stop','-st',default=None,help='Data de fim da ingestão',type=str)
args = parser.parse_args()
ORIGIN_CONNECTION = sqlalchemy.create_engine('sqlite:///../../data/database.db')
TARGET_CONNECTION = sqlalchemy.create_engine('sqlite:///../../data/featurestore.db')
query = import_query(f"{args.feature_store}.sql")
dates = define_dates(args.start,args.stop)
ingest_data('tb_'+args.feature_store,query,dates,ORIGIN_CONNECTION,TARGET_CONNECTION)

