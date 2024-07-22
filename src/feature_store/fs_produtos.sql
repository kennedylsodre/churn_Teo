WITH tb_transactions_product as (
    SELECT 
        trn.*
        ,prd.NameProduct 
        ,prd.QuantityProduct
FROM transactions trn 
LEFT JOIN transactions_product prd 
    on prd.idTransaction = trn.idTransaction
WHERE dtTransaction < '{date}' 
and dtTransaction >= DATE('{date}','-21 day')

),



tb_share as (
SELECT 
    idCustomer 
    ,sum(case when NameProduct = 'Airflow Lover' then QuantityProduct else 0 end ) as qtdAirflowLover
    ,sum(case when NameProduct = 'ChatMessage' then QuantityProduct else 0 end ) as qtdChatMessage
    ,sum(case when NameProduct = 'Churn_10pp' then QuantityProduct else 0 end ) as qtdChurn_10pp
    ,sum(case when NameProduct = 'Churn_2pp' then QuantityProduct else 0 end ) as qtdChurn_2pp
    ,sum(case when NameProduct = 'Churn_5pp' then QuantityProduct else 0 end ) as qtdChurn_5pp
    ,sum(case when NameProduct = 'Lista de presença' then QuantityProduct else 0 end ) as qtdListadepresença
    ,sum(case when NameProduct = 'Presença Streak' then QuantityProduct else 0 end ) as qtdPresençaStreak
    ,sum(case when NameProduct = 'R Lover' then QuantityProduct else 0 end ) as qtdRLover
    ,sum(case when NameProduct = 'Resgatar Ponei' then QuantityProduct else 0 end ) as qtdResgatarPonei
    ,sum(case when NameProduct = 'Troca de Pontos StreamElements' then QuantityProduct else 0 end ) as qtdTrocadePontosStreamElements

    ,sum(case when NameProduct = 'Airflow Lover' then pointsTransaction else 0 end ) as ptsAirflowLover
    ,sum(case when NameProduct = 'ChatMessage' then pointsTransaction else 0 end ) as ptsChatMessage
    ,sum(case when NameProduct = 'Churn_10pp' then pointsTransaction else 0 end ) as ptsChurn_10pp
    ,sum(case when NameProduct = 'Churn_2pp' then pointsTransaction else 0 end ) as ptsChurn_2pp
    ,sum(case when NameProduct = 'Churn_5pp' then pointsTransaction else 0 end ) as ptsChurn_5pp
    ,sum(case when NameProduct = 'Lista de presença' then pointsTransaction else 0 end ) as ptsListadepresença
    ,sum(case when NameProduct = 'Presença Streak' then pointsTransaction else 0 end ) as ptsPresençaStreak
    ,sum(case when NameProduct = 'R Lover' then pointsTransaction else 0 end ) as ptsRLover
    ,sum(case when NameProduct = 'Resgatar Ponei' then pointsTransaction else 0 end ) as ptsResgatarPonei
    ,sum(case when NameProduct = 'Troca de Pontos StreamElements' then pointsTransaction else 0 end ) as ptsTrocadePontosStreamElements

    ,1.0 * sum(case when NameProduct = 'Airflow Lover' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctAirflowLover
    ,1.0 * sum(case when NameProduct = 'ChatMessage' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctChatMessage
    ,1.0 * sum(case when NameProduct = 'Churn_10pp' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctChurn_10pp
    ,1.0 * sum(case when NameProduct = 'Churn_2pp' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctChurn_2pp
    ,1.0 * sum(case when NameProduct = 'Churn_5pp' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctChurn_5pp
    ,1.0 * sum(case when NameProduct = 'Lista de presença' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctListadepresença
    ,1.0 * sum(case when NameProduct = 'Presença Streak' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctPresençaStreak
    ,1.0 * sum(case when NameProduct = 'R Lover' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctRLover
    ,1.0 * sum(case when NameProduct = 'Resgatar Ponei' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctResgatarPonei
    ,1.0 * sum(case when NameProduct = 'Troca de Pontos StreamElements' then QuantityProduct else 0 end ) / sum(pointsTransaction) as pctTrocadePontosStreamElements

    ,1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' THEN QuantityProduct ELSE 0 END) / COUNT(DISTINCT DATE(dtTransaction)) AS avgChatLive
FROM tb_transactions_product
GROUP by idCustomer
 ) ,

tb_group as ( 
    SELECT 
        idCustomer
        ,NameProduct
        ,sum(QuantityProduct) as qtde
        ,sum(pointsTransaction) as points
    FROM tb_transactions_product 
    GROUP BY idCustomer,NameProduct

),

tb_rn as (

SELECT 
    * 
    ,row_number() over(partition by idCustomer order by qtde desc,points desc) rnQtde
from tb_group 
ORDER BY idCustomer ), 

tb_produto_max as (
    SELECT 
        * 
    FROM tb_rn 
    where rnQtde = 1

)

SELECT 
    '{date}' as dtRef
    ,shr.* 
    ,NameProduct
FROM tb_share shr 
LEFT JOIN tb_produto_max prd_max
    on prd_max.idCustomer = shr.idCustomer