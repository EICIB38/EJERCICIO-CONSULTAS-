SELECT * FROM tab_prod where id_prod in 
(select id_prod from tab_prod_prov where val_prod > '200000')