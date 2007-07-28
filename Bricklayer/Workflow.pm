package Bricklayer::Workflow;
# class to allow you to chain actions together in a workflow
# needs to examine a state and return you the options for the
# next action to run.
use Bricklayer::Workflow::State;

#Do states need to implement an inheritance mechanism?

sub workflow { #needs an identifier
	return Bricklayer::Workflow::State->new($_[0]);
}


# evaluate workflow

=head1 Workflow::State Useage example

my $state = $app->workflow();
#use example to create workflow states here
my @actions = $state->actions();
 #send actions to the UI
 #UI selects action sends back
my $state = $state->transition("mark_visible");

=cut

return 1;