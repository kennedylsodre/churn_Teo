WITH tb_rfv as ( 
    SELECT 
        cst.idCustomer
        ,COUNT(DISTINCT trn.dtTransaction) as Freq
        -- ,cst.PointsCustomer as vlr_pontos_cst
        -- ,cst.flEmail 
        ,CAST(min(julianday('{date}') - julianday(dtTransaction)) as INTEGER) + 1 as frequencia
        ,sum(
            CASE
                when pointsTransaction > 0 then pointsTransaction end) as vlr_pontos
    FROM customers cst
    LEFT JOIN transactions trn 
        ON cst.idCustomer = trn.idCustomer 
    LEFT JOIN transactions_product trn_prd 
        on trn_prd.idTransaction = trn.idTransaction
    WHERE trn.dtTransaction < '{date}'
    AND trn.dtTransaction >= DATE('{date}','-21 day')
    GROUP BY cst.idCustomer
) 

,tb_idade as ( 
   SELECT 
    rfv.idCustomer,
    CAST(MAX(julianday('{date}') - julianday(trn.dtTransaction)) AS INTEGER) + 1 AS idadeBaseDias
    FROM 
    tb_rfv rfv 
LEFT JOIN 
    transactions trn 
    ON rfv.idCustomer = trn.idCustomer
GROUP BY 
    rfv.idCustomer

)

SELECT 
    '{date}' as dtRef
    ,rfv.*
    ,idade.idadeBaseDias
    ,cst.flEmail
FROM tb_rfv rfv 
LEFT JOIN tb_idade idade 
    on idade.idCustomer = rfv.idCustomer
LEFT join customers cst 
    on cst.idCustomer = rfv.idCustomer

