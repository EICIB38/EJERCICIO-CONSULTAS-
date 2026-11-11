select concat (tab_ciud.nom_ciud, '-', tab_dptos.nom_dpto ) as tab_ciud_dpto
from tab_ciud
join tab_dptos on tab_ciud. id_dpto = tab_dptos.id_dpto