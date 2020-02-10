
cdef class Distribution:
    """A Distribution is a probability function
    that maps from variable value to a real value,
    that is, :math:`Pr(X=x)`.
    """
    def __getitem__(self, varval):
        """
        __getitem__(self, varval)
        Probability evaulation.
        Returns the probability of :math:`Pr(X=varval)`."""
        raise NotImplemented
    def __setitem__(self, varval, value):
        """
        __setitem__(self, varval, value)
        Sets the probability of :math:`X=varval` to be `value`.
        """
        raise NotImplemented
    def __hash__(self):
        return id(self)
    def __eq__(self, other):
        return id(self) == id(other)
    def __iter__(self):
        """Initialization of iterator over the values in this distribution"""
        raise NotImplemented
    def __next__(self):
        """Returns the next value of the iterator"""
        raise NotImplemented
    def probability(self, varval):
        return self[varval]

cdef class GenerativeDistribution(Distribution):
    """A GenerativeDistribution is a Distribution that additionally exhibits
    generative properties. That is, it supports :meth:`argmax` (or :meth:`mpe`)
    and :meth:`random` functions.  """
    def argmax(self, **kwargs):
        """
        argmax(self, **kwargs)
        Synonym for :meth:`mpe`.
        """
        return self.mpe(**kwargs)
    def mpe(self, **kwargs):
        """
        mpe(self, **kwargs)
        Returns the value of the variable that has the highest probability.
        """
        raise NotImplemented
    def random(self, **kwargs):
        # Sample a state based on the underlying belief distribution
        raise NotImplemented
    def get_histogram(self):
        """
        get_histogram(self)
        Returns a dictionary from state to probability"""
        raise NotImplemented

cdef class ObservationModel:
    """
    An ObservationModel models the distribution :math:`O(s',a,o)=\Pr(o|s',a)`.
    """
    def probability(self, observation, next_state, action, **kwargs):
        """
        probability(self, observation, next_state, action, **kwargs)
        Returns the probability of :math:`\Pr(o|s',a)`.

        Args:
            observation (Observation): the observation :math:`o`
            next_state (State): the next state :math:`s'`
            action (Action): the action :math:`a`
        Returns:
            float: the probability :math:`\Pr(o|s',a)`
        """
        raise NotImplemented
    def sample(self, next_state, action, **kwargs):
        """sample(self, next_state, action, **kwargs)
        Returns observation randomly sampled according to the
        distribution of this observation model.

        Args:
            next_state (State): the next state :math:`s'`
            action (Action): the action :math:`a`
        Returns:
            Observation: the observation :math:`o`
        """
        raise NotImplemented
    def argmax(self, next_state, action, **kwargs):
        """
        argmax(self, next_state, action, **kwargs)
        Returns the most likely observation"""
        raise NotImplemented
    def get_distribution(self, next_state, action, **kwargs):
        """
        get_distribution(self, next_state, action, **kwargs)
        Returns the underlying distribution of the model"""
        raise NotImplemented
    def get_all_observations(self):
        """
        get_all_observations(self)
        Returns a set of all possible observations, if feasible."""
        raise NotImplemented        
    
cdef class TransitionModel:
    """
    A TransitionModel models the distribution :math:`T(s,a,s')=\Pr(s'|s,a)`.
    """
    
    def probability(self, next_state, state, action, **kwargs):
        """
        probability(self, next_state, state, action, **kwargs)
        Returns the probability of :math:`\Pr(s'|s,a)`.

        Args:
            state (State): the state :math:`s`
            next_state (State): the next state :math:`s'`
            action (Action): the action :math:`a`
        Returns:
            float: the probability :math:`\Pr(s'|s,a)`
        """        
        raise NotImplemented
        
    def sample(self, state, action, **kwargs):
        """sample(self, state, action, **kwargs)
        Returns next state randomly sampled according to the
        distribution of this transition model.

        Args:
            state (State): the next state :math:`s`
            action (Action): the action :math:`a`
        Returns:
            State: the next state :math:`s'`
        """
        raise NotImplemented
    def argmax(self, state, action, **kwargs):
        """
        argmax(self, state, action, **kwargs)
        Returns the most likely next state"""
        raise NotImplemented
    def get_distribution(self, state, action, **kwargs):
        """
        get_distribution(self, state, action, **kwargs)
        Returns the underlying distribution of the model"""
        raise NotImplemented
    def get_all_states(self):
        """
        get_all_states(self)
        Returns a set of all possible states, if feasible."""
        raise NotImplemented

cdef class RewardModel:
    """A RewardModel models the distribution :math:`\Pr(r|s,a,s')` where
    :math:`r\in\mathbb{R}` with `argmax` denoted as denoted as
    :math:`R(s,a,s')`.  """
    def probability(self, reward, state, action, next_state, **kwargs):
        """
        probability(self, reward, state, action, next_state, **kwargs)
        Returns the probability of :math:`\Pr(r|s,a,s')`.

        Args:
            reward (float): the reward :math:`r`
            state (State): the state :math:`s`
            action (Action): the action :math:`a`
            next_state (State): the next state :math:`s'`
        Returns:
            float: the probability :math:`\Pr(r|s,a,s')`
        """        
        raise NotImplemented
        
    def sample(self, state, action, next_state, **kwargs):
        """sample(self, state, action, next_state, **kwargs)
        Returns reward randomly sampled according to the
        distribution of this reward model.

        Args:
            state (State): the next state :math:`s`
            action (Action): the action :math:`a`
            next_state (State): the next state :math:`s'`
        Returns:
            float: the reward :math:`r`
        """
        raise NotImplemented
    
    def argmax(self, state, action, next_state, **kwargs):
        """
        argmax(self, state, action, next_state, **kwargs)
        Returns the most likely reward"""
        raise NotImplemented
    def get_distribution(self, state, action, next_state, **kwargs):
        """get_distribution(self, state, action, next_state, **kwargs)
        Returns the underlying distribution of the model"""
        raise NotImplemented    

cdef class BlackboxModel:
    """
    A BlackboxModel is the generative distribution :math:`G(s,a)`
    which can generate samples where each is a tuploe :math:`(s',o,r)`.
    """    
    def sample(self, state, action, **kwargs):
        """
        sample(self, state, action, **kwargs)
        Sample (s',o,r) ~ G(s',o,r)"""
        raise NotImplemented
    
    def argmax(self, state, action, **kwargs):
        """
        argmax(self, state, action, **kwargs)
        Returns the most likely (s',o,r)"""
        raise NotImplemented

cdef class PolicyModel:
    """
    PolicyModel models the distribution :math:`\pi(a|s)`. It can
    also be treated as modeling :math:`\pi(a|h_t)` by regarding
    `state` parameters as `history`.

    The reason to have a policy model is to accommodate problems
    with very large action spaces, and the available actions may vary
    depending on the state (that is, certain actions have probabilty=0)"""
    
    def probability(self, action, state, **kwargs):
        """
        probability(self, action, state, **kwargs)
        Returns the probability of :math:`\pi(a|s)`.

        Args:
            action (Action): the action :math:`a`
            state (State): the state :math:`s`
        Returns:
            float: the probability :math:`\pi(a|s)`
        """
        raise NotImplemented
        
    def sample(self, state, **kwargs):
        """sample(self, state, **kwargs)
        Returns action randomly sampled according to the
        distribution of this policy model.

        Args:
            state (State): the next state :math:`s`

        Returns:
            Action: the action :math:`a`
        """
        raise NotImplemented
    
    def argmax(self, state, **kwargs):
        """
        argmax(self, state, **kwargs)
        Returns the most likely reward"""
        raise NotImplemented
    def get_distribution(self, state, **kwargs):
        """
        get_distribution(self, state, **kwargs)
        Returns the underlying distribution of the model"""
        raise NotImplemented
    def get_all_actions(self, *args, **kwargs):
        """
        get_all_actions(self, *args, **kwargs)
        Returns a set of all possible actions, if feasible."""
        raise NotImplemented
    def update(self, state, next_state, action, **kwargs):
        """
        update(self, state, next_state, action, **kwargs)
        Policy model may be updated given a (s,a,s') pair."""
        pass
    
# Belief distribution is just a distribution. There's nothing special,
# except that the update/abstraction function can be performed over them.
# But it would make the class hierarchy a lot more complicated if belief
# distribution is also made explicit, which means, for example, a belief
# distribution represented as a histogram would have to do multiple
# inheritance; doing so, the additional value is little.


"""Because T, R, O may be different for the agent versus the environment,
it does not make much sense to have the POMDP class to hold this information;
instead, Agent should have its own T, R, O, pi and the Environment should
have its own T, R. The job of a POMDP is only to verify whether a given state,
action, or observation are valid."""

cdef class POMDP:
    """
    A POMDP instance = agent (:class:`Agent`) + env (:class:`Environment`).

    __init__(self, agent, env, name="POMDP")
    """
    def __init__(self, agent, env, name="POMDP"):
        self.agent = agent
        self.env = env

cdef class Action:
    """
    The Action class. Action must be `hashable`.
    """
    def __eq__(self, other):
        raise NotImplemented
    def __hash__(self):
        raise NotImplemented        
cdef class State:
    """
    The State class. State must be `hashable`.
    """
    def __eq__(self, other):
        raise NotImplemented
    def __hash__(self):
        raise NotImplemented        

cdef class Observation:
    """
    The Observation class. Observation must be `hashable`.
    """
    def __eq__(self, other):
        raise NotImplemented
    def __hash__(self):
        raise NotImplemented        

cdef class Agent:
    """ An Agent operates in an environment by taking actions, receiving
    observations, and updating its belief. Taking actions is the job of a
    planner (:class:`Planner`), and the belief update is the job taken care of
    by the belief representation or the planner. But, the Agent supplies the
    :class:`TransitionModel`, :class:`ObservationModel`, :class:`RewardModel`,
    OR :class:`BlackboxModel` to the planner or the belief update algorithm. 

    __init__(self, init_belief,
             policy_model,
             transition_model=None,
             observation_model=None,
             reward_model=None,
             blackbox_model=None)
"""
    def __init__(self, init_belief,
                 policy_model,
                 transition_model=None,
                 observation_model=None,
                 reward_model=None,
                 blackbox_model=None):
        self._init_belief = init_belief
        self._policy_model = policy_model
        
        self._transition_model = transition_model
        self._observation_model = observation_model
        self._reward_model = reward_model
        self._blackbox_model = blackbox_model
        # It cannot be the case that both explicit models and blackbox model are None.
        if self._blackbox_model is None:
            assert self._transition_model is not None\
                and self._observation_model is not None\
                and self._reward_model is not None

        # For online planning
        self._cur_belief = init_belief
        self._history = ()

    @property
    def history(self):
        """history(self)
        Current history."""
        # history are of the form ((a,o),...);
        return self._history

    def update_history(self, real_action, real_observation):
        """update_history(self, real_action, real_observation)"""
        self._history += ((real_action, real_observation),)

    @property
    def init_belief(self):
        """
        init_belief(self)
        Initial belief distribution."""
        return self._init_belief

    @property
    def belief(self):
        """
        belief(self)
        Current belief distribution."""
        return self.cur_belief

    @property
    def cur_belief(self):
        return self._cur_belief

    def set_belief(self, belief, prior=False):
        """set_belief(self, belief, prior=False)"""
        self._cur_belief = belief
        if prior:
            self._init_belief = belief

    def sample_belief(self):
        """sample_belief(self)
        Returns a state (:class:`State`) sampled from the belief."""
        return self._cur_belief.random()

    @property
    def observation_model(self):
        return self._observation_model

    @property
    def transition_model(self):
        return self._transition_model

    @property
    def reward_model(self):
        return self._reward_model

    @property
    def policy_model(self):
        return self._policy_model

    @property
    def blackbox_model(self):
        return self._blackbox_model

    @property
    def generative_model(self):
        return self.blackbox_model

    def add_attr(self, attr_name, attr_value):
        """
        add_attr(self, attr_name, attr_value)
        A function that allows adding attributes to the agent.
        Sometimes useful for planners to store agent-specific information."""
        if hasattr(self, attr_name):
            raise ValueError("attributes %s already exists for agent." % attr_name)
        else:
            setattr(self, attr_name, attr_value)

    def update(self, real_action, real_observation, **kwargs):
        """
        update(self, real_action, real_observation, **kwargs)
        updates the history and performs belief update"""
        raise NotImplemented

    @property
    def all_states(self):
        """Only available if the transition model implements
        `get_all_states`."""
        return self.transition_model.get_all_states()

    @property
    def all_actions(self):
        """Only available if the policy model implements
        `get_all_actions`."""
        return self.policy_model.get_all_actions()

    @property
    def all_observations(self):
        """Only available if the observation model implements
        `get_all_observations`."""
        return self.observation_model.get_all_observations()

    def valid_actions(self, *args, **kwargs):
        return self.policy_model.get_all_actions(*args, **kwargs)


cdef class Environment:
    """An Environment maintains the true state of the world.
    For example, it is the 2D gridworld, rendered by pygame.
    Or it could be the 3D simulated world rendered by OpenGL.
    Therefore, when coding up an Environment, the developer
    should have in mind how to represent the state so that
    it can be used by a POMDP or OOPOMDP.

    The Environment is passive. It never observes nor acts.
    """
    def __init__(self, init_state,
                 transition_model,
                 reward_model):
        self._init_state = init_state
        self._transition_model = transition_model
        self._reward_model = reward_model
        self._cur_state = init_state

    @property
    def state(self):
        """Synonym for :meth:`cur_state`"""
        return self.cur_state

    @property
    def cur_state(self):
        """Current state of the environment"""
        return self._cur_state

    @property
    def transition_model(self):
        """The :class:`TransitionModel` underlying the environment"""
        return self._transition_model

    @property
    def reward_model(self):
        """The :class:`RewardModel` underlying the environment"""
        return self._reward_model
    
    def state_transition(self, action, execute=True, **kwargs):
        """
        state_transition(self, action, execute=True, **kwargs)
        Simulates a state transition given `action`. If `execute` is set to True,
        then the resulting state will be the new current state of the environment.

        Args:
            action (Action): action that triggers the state transition
            execute (bool): If True, the resulting state of the transition will become the current state.

        Returns:
            float or tuple: reward as a result of `action` and state transition, if `execute` is True
            (next_state, reward) if `execute` is False.
        """
        next_state, reward, _ = sample_explict_models(self.transition_model, None, self.reward_model,
                                                      self.state, action,
                                                      discount_factor=kwargs.get("discount_factor", 1.0))
        if execute:
            self._cur_state = next_state
            return reward
        else:
            return next_state, reward

    def provide_observation(self, observation_model, action, **kwargs):
        """
        provide_observation(self, observation_model, action, **kwargs)
        Returns an observation sampled according to :math:`\Pr(o|s',a)`
        where :math:`s'` is current environment :meth:`state`, :math:`a`
        is the given `action`, and :math:`\Pr(o|s',a)` is the `observation_model`.

        Args:
            observation_model (ObservationModel)
            action (Action)

        Returns:
            Observation: an observation sampled from :math:`\Pr(o|s',a)`.
        """
        return observation_model.sample(self.state, action, **kwargs)
    
    
cdef class Option(Action):
    """An option is a temporally abstracted action that
    is defined by (I, pi, B), where I is a initiation set,
    pi is a policy, and B is a termination condition

    Described in `Between MDPs and semi-MDPs:
    A framework for temporal abstraction in reinforcement learning`
    """
    def initiation(self, state, **kwargs):
        """
        initiation(self, state, **kwargs)
        Returns True if the given parameters satisfy the initiation set"""
        raise NotImplemented

    def termination(self, state, **kwargs):
        """termination(self, state, **kwargs)
        Returns a boolean of whether state satisfies the termination
        condition; Technically returning a float between 0 and 1 is also allowed."""
        raise NotImplemented

    @property
    def policy(self):
        """Returns the policy model (PolicyModel) of this option."""
        raise NotImplemented

    def sample(self, state, **kwargs):
        """
        sample(self, state, **kwargs)
        Samples an action from this option's policy.
        Convenience function; Can be overriden if don't
        feel like writing a PolicyModel class"""
        return self.policy.sample(state, **kwargs)
    
    def __eq__(self, other):
        raise NotImplemented
    
    def __hash__(self):
        raise NotImplemented

    # Remark in Sutton etal'99:
    # Note that even if a policy is Markov and all of the options
    # it selects are Markov, the corresponding flat policy is unlikely to be
    # Markov if any of the options are multi-step (temporally extended).
    #    --> that's why planning with options defined over an MDP
    #        results in a semi-MDP.


cpdef sample_generative_model(Agent agent, State state, Action action, float discount_factor=1.0):
    """
    sample_generative_model(Agent agent, State state, Action action, float discount_factor=1.0)
    :math:`(s', o, r) \sim G(s, a)`
    
    If the agent has transition/observation models, a `black box` will be created
    based on these models (i.e. :math:`s'` and :math:`o` will be sampled according
    to these models).

    Args:
        agent (Agent): agent that supplies all the models
        state (State)
        action (Action)
        discount_factor (float): Defaults to 1.0; Only used when `action` is an :class:`Option`.

    Returns:
        tuple: :math:`(s', o, r, n_steps)`
    """
    cdef tuple result

    if agent.transition_model is None:
        result = agent.generative_model.sample(state, action)
    else:
        result = sample_explict_models(agent.transition_model,
                                       agent.observation_model,
                                       agent.reward_model,
                                       state,
                                       action,
                                       discount_factor)
    return result


cpdef sample_explict_models(TransitionModel T, ObservationModel O, RewardModel R,
                            State state, Action action, float discount_factor=1.0):
    """
    sample_explict_models(TransitionModel T, ObservationModel O, RewardModel R, State state, Action action, float discount_factor=1.0)
    """
    cdef State next_state
    cdef Observation observation
    cdef float reward
    cdef Option option
    cdef int nsteps = 0

    if isinstance(action, Option):
        # The action is an option; simulate a rollout of the option
        option = action
        if not option.initiation(state):
            # state is not in the initiation set of the option. This is
            # similar to the case when you are in a particular (e.g. terminal)
            # state and certain action cannot be performed, which will still
            # be added to the PO-MCTS tree because some other state with the
            # same history will allow this action. In this case, that certain
            # action will lead to no state change, no observation, and 0 reward,
            # because nothing happened.
            if O is not None:
                return state, None, 0, 0
            else:
                return state, 0, 0

        reward = 0
        step_discount_factor = 1.0
        while not option.termination(state):
            action = option.sample(state)
            next_state = T.sample(state, action)
            # For now, we don't care about intermediate observations (future work?).
            reward += step_discount_factor * R.sample(state, action, next_state)
            step_discount_factor *= discount_factor
            state = next_state
            nsteps += 1
        # sample observation at the end, where action is the last action.
        # (doesn't quite make sense to just use option as the action at this point.)
    else:
        next_state = T.sample(state, action)
        reward = R.sample(state, action, next_state)
        nsteps += 1
    if O is not None:
        observation = O.sample(next_state, action)
        return next_state, observation, reward, nsteps
    else:
        return next_state, reward, nsteps
    
