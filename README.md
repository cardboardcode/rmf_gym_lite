## **What Is This?**

This is a collection of **lightweight simulated RMF deployments** you can run locally on your workstation to test RMF task workflows and deconflictions.

These deployments uses [invisibot](https://github.com/cardboardcode/invisibot/tree/devel/gary) and [fleet_adapter_invisibot](https://github.com/cardboardcode/fleet_adapter_invisibot) in order to skip setting up a physical robot as well as avoid using computationally-heavy Gazebo simulations.

> [!TIP]
> `rmf_gym_lite` is best used in order to help identify potential deadlocks in your RMF Map Building `.yaml` file and allow ease of finetuning based on [recommended graph strategies](https://osrf.github.io/ros2multirobotbook/integration_nav-maps-strategies.html).

## **Build**

```bash
git clone https://github.com/cardboardcode/rmf_gym_lite.git --depth 1 --single-branch main
```

```bash
bash scripts/1_pull_docker_compose.bash
```

## **Run**

```bash
bash scripts/2_deploy_docker_compose.bash
```

> To stop the deployment, run the command below:
> `bash scripts/3_stop_docker_compose.bash`

## **Scenario(s)**

### **triple_H**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/triple_h.png)

### **simple_lift**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/simple_lift.png)

### **simple_doors**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/simple_doors.gif)

### **delivery_queue**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/simple_queue.png)

### **lift_queue**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/lift_queue.png)

### **narrow_corridor**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/narrow_corridor.png)


## **Maintainer(s)**
- [cardboardcode](https://github.com/cardboardcode)
