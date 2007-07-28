package Bricklayer::Workflow::State;
#use JSON;
use base qw{Bricklayer::Class::Builder Bricklayer::Class::Util};
#Bricklayer Workflow State class. Implements the ability to
#store and retrieve a state definition. Reports the valid
#actions you can take from this state and the state's 
#name and description

#Attributes
sub name { #returns the state's name
	return $_[0]->attribute('Scalar', 'Name', $_[1]);
}

sub type {
	return $_[0]->attribute('Scalar', 'Type', $_[1]);
}

=head1 Bricklayer::Workflow::State definition

 {Name => '', Actions => []}

=cut

sub actions { #returns the states valid actions
	return $_[0]->attribute('HASH', 'Actions', {$_[1]->name()=> $_[1]}, 'Bricklayer::Workflow::State::Action'); }

sub targetter {
	return $_[0]->attribute('Bricklayer::Workflow::State', 'Actions', $_[1]); }

sub result { return $_[0]->attribute('Scalar', 'Result', $_[1]); }

# transition methods
sub transition {
	my ($self, $action) = @_;
	my $target = $self->actions->{$action}->target();
	
	my $plugin = $self->app()->plugins()->load($self->actions()->{$action}->plugin(), "action")->run();
	return $target;
} 

#Utility Packages
package Bricklayer::Workflow::State::Action;
use base qw{Bricklayer::Class::Util};

sub new { #returns an action object
	my ($name, $desc, $plugin, $target) = @_[1..$#_];
	my $self = bless({}, ref($_[0] || $_[0]));
	if ($name) {
		$self->name($name);		
		$self->desc($desc) if ($desc);
		if ($plugin && $type) {
			$self->name($plugin);
			$self->name($type);	
		}
		$self->target($target) if ($target);
		
	}
	return $self;
}

sub name {return $_[0]->attribute('SCALAR', 'Name', $_[1]) }
sub desc {return $_[0]->attribute('SCALAR', 'Description', $_[1]) }
sub plugin {return $_[0]->attribute('SCALAR', 'Plugin', $_[1]) }
sub type {return $_[0]->attribute('SCALAR', 'Type', $_[1]) }
sub target {return $_[0]->attribute('Bricklayer::Workflow::State', 'Target', $_[1]) }

=head1 Bricklayer::Workflow::State::Action definition

{Name => '', Description => '', Plugin => '', Type => '', Target => ''}

=cut

=head1 Building a Bricklayer::Workflow::State Object

my $Initial = Bricklayer::Workflow::State::new($app);
$Initial->name("Initial");
$Initial->type("Initial");
my $trans1 = Bricklayer::Workflow::State::new($app);
$trans1->name("transit 1");
$trans1->type("transitional");
my $trans1 = Bricklayer::Workflow::State::new($app);
$trans2->name("transit 2");
$trans2->type->("final");

$trans1->actions([Bricklayer::Workflow::State::Action->new("transit2", "test", "transittwo", $trans2)]);

$Initial->actions([Bricklayer::Workflow::State::Action->new("transit1", "test", "transitone", $trans1), 
				   Bricklayer::Workflow::State::Action->new("transit2", "test", "transittwo", $trans2)]);
=cut

=head1 Using a Workflow::State Object
my $wf = $Initial;

$wf = $wf->transition("transit1");
$wf = $wf->transition("transit2");

=cut
return 1;