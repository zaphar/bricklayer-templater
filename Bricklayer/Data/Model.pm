###################################################################
# Description of Database Library for use in Bricklayer Data Plugins
#
# Contains the Data structures and methods to properly access
# and modify sql statements.
#
#
#
#
###################################################################
package Bricklayer::Data::Model;
use Bricklayer::Data::Model::Schema;
use Bricklayer::Data::Model::Table;
use Bricklayer::Data::Model::Fields;

#external Libraries
use SQL::Abstract;

#Object Initiator
sub new { #expects the driver to be passed on creation
	my $schema = Bricklayer::Data::Model::Schema->new();
	my $table = Bricklayer::Data::Model::Table->new();
	my $fields = Bricklayer::Data::Model::Fields->new();
	return bless({Schema => $schema,
				  Tables => $table,
				  Fields => $fields}, ref($_[0]) || $_[0])
}

#Accessor Methods

sub schema { #used to access current schema from a Data::Model object
		return $_[0]->{Schema};
}

sub table { #used to access current table from a Data::Model object
		return $_[0]->{Tables};
}

sub fields { #used to access field list from a Data::Model object
	return $_[0]->{Fields};
}

sub where {
	return $_[0] unless ref($_[1]) eq 'HASH';
	# check that field name exists
	my @fields = $_[0]->fields()->field_names();
	foreach (@fields) {
		$exists = 1 if Bricklayer::Data::Model::Fields::field_name($_[1]);
	}	
	# if the field exists store it in Where attribute
	if ($exists) {
		$_[0]->{Where} = $_[1];
		return $_[0];
	}
	return $_[0];
}

sub _SQL {
	return $_[0]->{SQLBUILDER} if $_[0]->{SQLBUILDER};
	$_[0]->{SQLBUILDER} = SQL::Abstract->new(); #our default builder;
	return $_[0];
}

sub set_builder {
	$_[0]->{SQLBUILDER} = $_[1];
}

sub select {
	my $table = $_[0]->table()->[0];
	my @fields = $_[0]->fields()->field_names;
	my @order = @$_[1]
		if $_[1];
	
	my $sql = $_[0]->_SQL->select($table, \@fields, $_[0]->{Where}, \@order);
	return $sql;
}

sub insert {
	
}

sub update {
	
}

sub delete {
	
}

sub drop {
	
}

sub create {
	
}

# Model example code
# my $driver = code to load driver here;
# my $model = $driver->model();
# $model->schema->bindto('schema name');
# $model->table->bindto('table_name'); #which table are we querying
# $model->fields->bindto(['field1', 'field2']); #which fields are we retrieving or inserting into
# $driver->select({'field1' => 'value1'});
# $driver->select({'*' => 'value1'});
return 1;