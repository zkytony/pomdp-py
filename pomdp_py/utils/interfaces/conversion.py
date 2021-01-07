"""
Provides utility to convert a POMDP written in pomdp_py to
a POMDP file format (.pomdp or .pomdpx). Output to a file.
"""

def to_pomdp_file(agent, output_path,
                  discount_factor=0.95):
    """
    Pass in an Agent, and use its components to generate
    a .pomdp file to `output_path`.

    The .pomdp file format is specified at:
    http://www.pomdp.org/code/pomdp-file-spec.html

    Note:
    * It is assumed that the reward is independent of the observation.
    * The state, action, and observations of the agent must be
      explicitly enumerable.
    * The state, action and observations of the agent must be
      convertable to a string that does not contain any blank space.

    Args:
        agent (~pomdp_py.framework.basics.Agent): The agent
        output_path (str): The path of the output file to write in.
        discount_factor (float): The discount factor
    """
    # Preamble
    try:
        all_states = list(agent.all_states)
        all_actions = list(agent.all_actions)
        all_observations = list(agent.all_observations)
    except NotImplementedError:
        print("S, A, O must be enumerable for a given agent to convert to .pomdp format")

    content = "discount: %f\n" % discount_factor
    content += "values: reward\n" # We only consider reward, not cost.

    list_of_states = " ".join(str(s) for s in all_states)
    assert len(list_of_states.split(" ")) == len(all_states),\
        "states must be convertable to strings without blank spaces"
    content += "states: %s\n" % list_of_states

    list_of_actions = " ".join(str(a) for a in all_actions)
    assert len(list_of_actions.split(" ")) == len(all_actions),\
        "actions must be convertable to strings without blank spaces"
    content += "actions: %s\n" % list_of_actions

    list_of_observations = " ".join(str(o) for o in all_observations)
    assert len(list_of_observations.split(" ")) == len(all_observations),\
        "observations must be convertable to strings without blank spaces"
    content += "observations: %s\n" % list_of_observations

    # Starting belief state - they need to be normalized
    total_belief = sum(agent.belief[s] for s in all_states)
    content += "start: %s\n" % (" ".join(["%f" % (agent.belief[s]/total_belief)
                                          for s in all_states]))

    # State transition probabilities - they need to be normalized
    for s in all_states:
        for a in all_actions:
            probs = []
            for s_next in all_states:
                prob = agent.transition_model.probability(s_next, s, a)
                probs.append(prob)
            total_prob = sum(probs)
            for i, s_next in enumerate(all_states):
                prob_norm = probs[i] / total_prob
                content += 'T : %s : %s : %s %f\n' % (a, s, s_next, prob_norm)

    # Observation probabilities - they need to be normalized
    for s_next in all_states:
        for a in all_actions:
            probs = []
            for o in all_observations:
                prob = agent.observation_model.probability(o, s_next, a)
                probs.append(prob)
            total_prob = sum(probs)
            for i, o in enumerate(all_observations):
                prob_norm = probs[i] / total_prob
                content += 'O : %s : %s : %s %f\n' % (a, s_next, o, prob_norm)

    # Immediate rewards
    for s in all_states:
        for a in all_actions:
            for s_next in all_states:
                # We will take the argmax reward, which works for deterministic rewards.
                r = agent.reward_model.sample(s, a, s_next)
                content += 'R : %s : %s : %s : *  %f\n' % (a, s, s_next, r)

    with open(output_path, "w") as f:
        f.write(content)