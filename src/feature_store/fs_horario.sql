
WITH tb_transaction_hour as ( 
SELECT 
    idCustomer
    ,pointsTransaction
    ,CAST(strftime('%H',DATETIME(dtTransaction,'-3 hour')) as integer) as hour_transaction
FROM transactions  
WHERE dtTransaction < '{date}'
and dtTransaction >= date('{date}','-21 day'))

,tb_share as (
    SELECT 
        idCustomer
        ,sum(case when hour_transaction >= 8 and hour_transaction < 12 then abs(pointsTransaction) else 0 end ) as qtdPointsManha
        ,sum(case when hour_transaction >= 12 and hour_transaction < 18 then abs(pointsTransaction) else 0 end ) as qtdPointsTarde
        ,sum(case when hour_transaction >= 18 and hour_transaction < 23 then abs(pointsTransaction) else 0 end) as qtdPointsNoite

        ,1.0 * sum(case when hour_transaction >= 8 and hour_transaction < 12 then abs(pointsTransaction) else 0 end ) / sum(abs(pointsTransaction)) as pctPointsManha
        ,1.0 * sum(case when hour_transaction >= 12 and hour_transaction < 18 then abs(pointsTransaction) else 0 end ) / sum(abs(pointsTransaction)) as pctPointsTarde
        ,1.0 * sum(case when hour_transaction >= 18 and hour_transaction < 23 then abs(pointsTransaction) else 0 end) / sum(abs(pointsTransaction)) as pctPointsNoite

        ,sum(case when hour_transaction >= 8 and hour_transaction < 12 then 1 else 0 end ) as qtdTransactionsManha
        ,sum(case when hour_transaction >= 12 and hour_transaction < 18 then 1 else 0 end ) as qtdTransactionsTarde
        ,sum(case when hour_transaction >= 18 and hour_transaction < 23 then 1 else 0 end) as qtdTransactionsNoite

        ,1.0 * sum(case when hour_transaction >= 8 and hour_transaction < 12 then 1 else 0 end ) / sum(1) as pctTransactionsManha
        ,1.0 * sum(case when hour_transaction >= 12 and hour_transaction < 18 then 1 else 0 end ) / sum(1) as pctTransactionsTarde
        ,1.0 * sum(case when hour_transaction >= 18 and hour_transaction < 23 then 1 else 0 end) / sum(1) as pctTransactionsNoite

    FROM tb_transaction_hour 
    GROUP by idCustomer)

SELECT 
    '{date}' as dtRef
    ,*
FROM tb_share