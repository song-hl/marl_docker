# marl_docker

## zip package url

./IsaacGymEnvs.zip                  https://github.com/NVIDIA-Omniverse/IsaacGymEnvs  
./IsaacGym_Preview_4_Package.tar.gz https://developer.nvidia.com/isaac-gym  
./mujoco210-linux-x86_64.tar.gz     https://mujoco.org/download/mujoco210-linux-x86_64.tar.gz  
./multiagent_mujoco.zip             https://github.com/schroederdewitt/multiagent_mujoco  
./SC2.4.10.zip                      http://blzdistsc2-a.akamaihd.net/Linux/SC2.4.10.zip  
./SMAC_Maps.zip                     https://github.com/oxwhirl/smac/releases/download/v0.1-beta1/SMAC_Maps.zip 
./DexterousHands.zip                https://github.com/PKU-MARL/DexterousHands 

## change package dependence

    change multiagent_mujoco :line 43 in setup.py -> "gym>=0.10.8" 