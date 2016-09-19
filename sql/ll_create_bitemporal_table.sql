CREATE OR REPLACE FUNCTION bitemporal_internal.ll_create_bitemporal_table(
    p_schema text,
    p_table text,
    p_table_definition text,
    p_business_key text)
  RETURNS boolean AS
$BODY$
DECLARE 
v_business_key_name text;
v_business_key_gist text;
v_serial_key_name text;
BEGIN
v_serial_key_name :=p_table||'_key serial';
v_business_key_name :=p_table||'_'||translate(p_business_key, ', ','_')||'_assert_eff_excl';
v_business_key_gist :=replace(p_business_key, ',',' WITH =,')||' WITH =, asserted WITH &&, effective WITH &&';
--raise notice 'gist %',v_business_key_gist;
EXECUTE format($create$
CREATE TABLE %s.%s (
                 %s
                 ,%s
                 ,effective temporal_relationships.timeperiod
                 ,asserted temporal_relationships.timeperiod
                 ,row_created_at timestamptz NOT NULL DEFAULT now()
                 ,CONSTRAINT %s EXCLUDE 
                   USING gist (%s)
                    )
                 $create$
                 ,p_schema
                 ,p_table
                 ,v_serial_key_name
                 ,p_table_definition
                 ,v_business_key_name
                 ,v_business_key_gist
                 ) ;
 RETURN ('true');  
 EXCEPTION WHEN OTHERS THEN
RETURN ('false');             
END;
$BODY$
  LANGUAGE plpgsql;