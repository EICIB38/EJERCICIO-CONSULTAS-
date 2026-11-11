SELECT p.id_prov, p.nom_prov
FROM tab_prov p
WHERE EXISTS ( 
		SELECT '1' 
		FROM tab_enc_compra e 
		WHERE  e.id_prov = p.id_prov)