namespace Tito;

class QueryBuilder
{

  protected con;
  protected _select;
  protected _from;
  protected _where;
  protected _join = "";
  protected _limit;
  protected _offset;
  protected _order;
  protected _param = [];
  protected _config;
  public stmt = [];
  public compiled;

  public function select(sql = "*")
  {
    if(is_null(this->_select))
    {
      let this->_select = "SELECT " . sql;
    }
    else
    {
      let this->_select = this->_select . "," . sql;
    }
    return this;
  }

  public function from(table)
  {
    if(is_null(table))
    {
      throw new \Exception("Table must be specified");
    }

    let this->_from = " FROM " . table;
    return this;
  }

  public function where(param = null, junction ="AND", separate = "AND")
  {
    if(junction != "OR")
    {
      let junction = "AND";
    }
    if(separate != "OR")
    {
      let separate = "AND";
    }
    if(is_null(this->_where))
    {
      let this->_where = " WHERE ";
    }
    else
    {
      let this->_where = this->_where . " " . separate . " ";
    }

    if(is_null(param))
    {
      return this;
    }

    if(is_string(param))
    {
      var conditions, c, idents, keys = [], values = [], field, paramold;
      let paramold = str_ireplace([" or "," and "," xor "," is "," not "], [" OR "," AND "," XOR "," IS "," NOT "], param);
      let param = str_replace(["(",")"],["",""], param);

      let conditions = preg_split("/(AND|OR|XOR)/i", param);

      for c in conditions
      {
          let idents = preg_split("/(>=|<=|!=|<>|=|>|<|IS NOT|IS)/i", c);
      		if(strtoupper(trim(idents[1])) != "NULL")
      		{
            let field = trim(idents[0]);
            if(strpos(field, ".")>0){
              let field = substr(field, strpos(field, ".")+1-strlen(field));
            }
            array_push(keys, ":". field);
      			array_push(values, trim(idents[1]));
            let this->_param[":".field] = trim(trim(idents[1]),"''");
      		}
      }

      let this->_where = this->_where . str_replace(values, keys, paramold);
      return this;
    }
    if(is_array(param))
    {
      var k, v, prep, bind, arg, operator, alias, match, j, l;
      let l = 0;
      let this->_where = this->_where . "(";
      for k, v in param
      {
        let j = is_int(k) ? v : k;

        if(strpos(j, ".")>=0)
        {
          let arg = explode(".", j);
          let prep = arg[1];
          let alias = arg[0].".";
        }
        else
        {
          let prep = is_null(v) ? k : v;
          let alias = "";
        }

        if(preg_match("/!=|<>|>=|<=|<|>|=|IS NOT|IS/i", prep, match, PREG_OFFSET_CAPTURE))
        {
          let arg = explode(match[0][0], prep);
          let operator = match[0][0];
          let bind = trim(arg[0]);
          if(v=="")
          {
            let v = trim(arg[1]);
          }
        }
        else
        {
            let bind = trim(prep);
            let operator = "=";
        }
        if(l >0){
          let this->_where = this->_where . " " . junction . " ";
        }
        let l = l + 1;
        let this->_where = this->_where .alias . bind ." ". operator . " :".bind;
        let this->_param[":".bind] = v;
      }
      let this->_where = this->_where . ")";
      return this;
    }
  }

  public function join(table = null, relation = null, rel = "INNER")
  {
    if(is_null(rel))
    {
      let rel = "INNER";
    }

    if(table == null)
    {
      return this;
    }

    let this->_join = this->_join ." ". rel . " JOIN ". table;

    if(! is_null(relation))
    {
      let this->_join = this->_join . " ON " . relation;
    }
    return this;
  }

  public function limit(limit="10", offset=0)
  {
    if(is_null(limit))
    {
      return this;
    }
    let this->_limit = " LIMIT " . offset . ", ". limit;
    return this;
  }

  public function order(arg = null)
  {
    if(is_NULL(arg))
    {
      return this;
    }
    let this->_order = " ORDER BY ".arg;
    return this;
  }

  public function get()
  {
    var k, v, sql;
    let sql = this->_select . this->_from . this->_join . this->_where . this->_order . this->_limit;
    let this->stmt["query_string"] = sql;

    if(! empty(this->_param))
    {
      for k, v in this->_param
      {
        let sql = str_replace(k, is_string(v) ? "'".v."'" : v, sql);
      }
    }
    let this->compiled = sql;
    let this->stmt["param"] = this->_param;
    let this->stmt["sql"] = sql;
    this->clear();
    return this;
  }


  private function clear()
  {
    let this->_select = "SELECT ";
    let this->_from = " FROM ";
    let this->_where = " WHERE ";
  }

}
