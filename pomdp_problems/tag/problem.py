import pomdp_py
import random
from pomdp_problems.tag.env.env import *
from pomdp_problems.tag.env.visual import *
from pomdp_problems.tag.agent.agent import *
from pomdp_problems.tag.example_worlds import *
import time

class TagProblem(pomdp_py.POMDP):

    def __init__(self,
                 init_robot_position,
                 init_target_position,
                 grid_map,
                 pr_move_away=0.8,
                 pr_stay=0.2,
                 small=1,
                 big=10,
                 prior="uniform"):
        init_state = TagState(init_robot_position,
                              init_target_position,
                              False)
        env = TagEnvironment(init_state,
                             grid_map,
                             pr_move_away=pr_move_away,
                             pr_stay=pr_stay,
                             small=1,
                             big=10)
        if prior == "uniform":
            prior = {}
        elif prior == "informed":
            prior = {init_target_position: 1.0}
        else:
            raise ValueError("Unrecognized prior type: %s" % prior)

        init_belief = initialize_belief(grid_map, init_robot_position, prior=prior)
        agent = TagAgent(init_belief,
                         grid_map,
                         pr_move_away=pr_move_away,
                         pr_stay=pr_stay,
                         small=1,
                         big=10)
        super().__init__(agent, env,
                         name="TagProblem")


def solve(problem,
          max_depth=10,  # planning horizon
          discount_factor=0.99,
          planning_time=1.,       # amount of time (s) to plan each step
          exploration_const=1000, # exploration constant
          visualize=True,
          max_time=120,  # maximum amount of time allowed to solve the problem
          max_steps=500): # maximum number of planning steps the agent can take.
    
    planner = pomdp_py.POUCT(max_depth=max_depth,
                             discount_factor=discount_factor,
                             planning_time=planning_time,
                             exploration_const=exploration_const,
                             rollout_policy=problem.agent.policy_model)
    if visualize:
        viz = TagViz(problem.env, controllable=False)
        if viz.on_init() == False:
            raise Exception("Environment failed to initialize")
        viz.update(None,
                   None,
                   problem.agent.cur_belief)                
        viz.on_render()

    _time_used = 0
    _find_actions_count = 0
    _total_reward = 0  # total, undiscounted reward
    for i in range(max_steps):
        # Plan action
        _start = time.time()
        real_action = planner.plan(problem.agent)
        _time_used += time.time() - _start
        if _time_used > max_time:
            break  # no more time to update.

        # Execute action
        reward = problem.env.state_transition(real_action, execute=True)

        # Receive observation
        _start = time.time()
        real_observation = \
            problem.env.provide_observation(problem.agent.observation_model, real_action)

        # Updates
        problem.agent.clear_history()  # truncate history
        problem.agent.update_history(real_action, real_observation)
        planner.update(problem.agent, real_action, real_observation)
        belief_update(problem.agent, real_action, real_observation)
        _time_used += time.time() - _start

        # Info and render
        _total_reward += reward
        print("==== Step %d ====" % (i+1))
        print("Action: %s" % str(real_action))
        print("Observation: %s" % str(real_observation))
        print("Reward: %s" % str(reward))
        print("Reward (Cumulative): %s" % str(_total_reward))
        print("Find Actions Count: %d" %  _find_actions_count)
        if isinstance(planner, pomdp_py.POUCT):
            print("__num_sims__: %d" % planner.last_num_sims)
            
        if visualize:
            viz.update(real_action,
                       real_observation,
                       problem.agent.cur_belief)
            viz.on_loop()
            viz.on_render()
            
        # Termination check
        if problem.env.state.target_found:
            print("Done!")
            break
        if _time_used > max_time:
            print("Maximum time reached.")
            break
        
if __name__ == "__main__":
    worldstr, robotstr = world0
    grid_map = GridMap.from_str(worldstr)
    free_cells = grid_map.free_cells()
    init_robot_position = random.sample(free_cells, 1)[0]
    init_target_position = random.sample(free_cells, 1)[0]
    
    problem = TagProblem(init_robot_position,
                         init_target_position,
                         grid_map,
                         pr_move_away=0.8,
                         pr_stay=0.2,
                         small=1,
                         big=10,
                         prior="uniform")
    solve(problem,
          max_depth=10,
          discount_factor=0.99,
          planning_time=1.,
          exploration_const=1000,
          visualize=True,
          max_time=120,
          max_steps=500)