select id_prov,nom_prov,ape_prov val_cupocre,
		case 
			WHEN val_cupocre >= 5000000 then  'cupo alto'
			when val_cupocre between 3000000 and 4999999 then  'cupo medio'
			else 'cupo bajo'
		end as clasificacion_cupo
from tab_prov