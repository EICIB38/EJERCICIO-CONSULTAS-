select  id_factura, count(*) as total_lineas
from tab_det_compra 
group by id_factura
having  count(*) > '1'