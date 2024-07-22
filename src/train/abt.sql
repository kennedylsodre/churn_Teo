with tb_fl_churn as (    
    SELECT 
        t1.*
        ,CASE WHEN t2.dtRef IS NOT NULL THEN 1 ELSE 0 END as flChurn
    FROM tb_fs_general t1 
    LEFT JOIN tb_fs_general t2 
        on t1.dtRef = DATE(t2.dtRef,'-21 day') and t1.idCustomer = t2.idCustomer
    WHERE (t1.dtRef < date('2024-07-13','-21 day') 
    and strftime('%d',t1.dtRef) ='01')
    or t1.dtRef = date('2024-07-13','-21 day') 
)

SELECT 
    t1.*

    ,t2.qtdPointsManha
    ,t2.qtdPointsTarde
    ,t2.qtdPointsNoite
    ,t2.pctPointsManha
    ,t2.pctPointsTarde
    ,t2.pctPointsNoite
    ,t2.qtdTransactionsManha
    ,t2.qtdTransactionsTarde
    ,t2.qtdTransactionsNoite
    ,t2.pctTransactionsManha
    ,t2.pctTransactionsTarde
    ,t2.pctTransactionsNoite

    ,t3.saldopoints21dias
    ,t3.saldopoints14days
    ,t3.saldopoints7days
    ,t3.totalpointsacumulado21dias
    ,t3.totalpointsacumulado14dias
    ,t3.totalpointsacumulado7dias
    ,t3.totalpointsresgatados21dias
    ,t3.totalpointsresgatados14dias
    ,t3.totalpointsresgatados7dias
    ,t3.saldopointsvida
    ,t3.pointsacumuladovida
    ,t3.pointsresgatadosvida
    ,t3.pointspordia

    ,t4.qtdAirflowLover
    ,t4.qtdChatMessage
    ,t4.qtdChurn_10pp
    ,t4.qtdChurn_2pp
    ,t4.qtdChurn_5pp
    ,t4.qtdListadepresenca
    ,t4.qtdPresencaStreak
    ,t4.qtdRLover
    ,t4.qtdRLover
    ,t4.qtdResgatarPonei
    ,t4.qtdTrocadePontosStreamElements
    ,t4.ptsAirflowLover
    ,t4.ptsChatMessage
    ,t4.ptsChurn_10pp
    ,t4.ptsChurn_2pp
    ,t4.ptsChurn_5pp
    ,t4.ptsListadepresenca
    ,t4.ptsPresencaStreak
    ,t4.ptsRLover
    ,t4.ptsResgatarPonei
    ,t4.ptsTrocadePontosStreamElements
    ,t4.pctAirflowLover
    ,t4.pctChatMessage
    ,t4.pctChurn_10pp
    ,t4.pctChurn_2pp
    ,t4.pctChurn_5pp
    ,t4.pctListadepresenca
    ,t4.pctPresencaStreak
    ,t4.pctRLover
    ,t4.pctResgatarPonei
    ,t4.pctTrocadePontosStreamElements
    ,t4.avgChatLive
    ,t4.NameProduct    

    ,t5.qtdeDiasD21
    ,t5.qtdeDiasD14
    ,t5.qtdeDiasD7
    ,t5.avgLiveMinutes
    ,t5.sumLiveMinutes
    ,t5.minLiveMinutes
    ,t5.maxLiveMinutes
    ,t5.qtdeTransacaoVida
    ,t5.avgTransacaoDia    

FROM tb_fl_churn t1
LEFT JOIN tb_fs_horario t2 
    on t1.idCustomer = t2.idCustomer and t1.dtRef = t2.dtRef
LEFT JOIN tb_fs_pontos t3
    on t1.idCustomer = t3.idCustomer and t1.dtRef = t3.dtRef
LEFT join tb_fs_produtos t4 
    on t4.idCustomer = t1.idCustomer and t1.dtRef = t4.dtRef
LEFT JOIN tb_fs_transacoes t5 
    on t5.idCustomer = t1.idCustomer and t1.dtRef = t5.dtRef



