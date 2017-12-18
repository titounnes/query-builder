<?php
/*
$stat= "(user >= 24 or id = 'foo' and foo IS NOT NULL) ";
$stat = str_replace(['(',')'],['',''], $stat);
$stat = str_ireplace([' or ',' and ',' xor ', ' is ',' not '], [' OR ', ' AND ',' XOR ',' IS ',' NOT '], $stat);
$param = [];
$bind = [];
$conditions = preg_split("/(AND|OR|XOR)/i", $stat);
foreach($conditions as $c){
    $idents = preg_split("/(>=|<=|!=|<>|=|>|<|IS NOT|IS)/i", $c);
		if(strtoupper(trim($idents[1]))!='NULL')
		{
			array_push($param, trim($idents[1]));
			array_push($bind, ':'.trim($idents[0]));
		}
		print_r($param);
}
$qs = str_replace($param, $bind, $stat );
print_r($qs);
//exit;
*/
use Tito\QueryBuilder;
use Tito\Driver\MyPdo;
$config = [
	'dsn' => "mysql",
	'host' => 'localhost',
	'dbname' => 'bpptpm',
	'uname' => 'root',
	'psw' => '',
];


$a = new QueryBuilder();
$a->select('u.username')
	->select('u.id')
	->select('ug.group_id, g.name')
	->from('users u')
	->where(['u.id>=' => 24,'u.name'=>'operator'],'OR','AND')
  ->join('users_groups ug','ug.user_id=u.id')
  ->join('groups g','ug.group_id=g.id')
  ->order('u.name DESC')
  ->get();
print_r($a->compiled);

$c = new MyPdo();
$b = $c->execute($config, $a->stmt);
while($x=$b->fetchObject()){
  echo($x->name)."\n";
}
//print_r($b->fetchObject());
//print_r($c->execute($config, $a->stmt)->fetch());

echo "\n";
