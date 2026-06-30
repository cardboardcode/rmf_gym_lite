## **What Is This?**

> [!INFO]
> This is a collection of **lightweight simulated RMF deployments** you can run locally on your workstation to test RMF task workflows and deconflictions.

These deployments uses [invisibot](https://github.com/cardboardcode/invisibot/tree/devel/gary) and [fleet_adapter_invisibot](https://github.com/cardboardcode/fleet_adapter_invisibot) in order to skip setting up a physical robot as well as avoid using computationally-heavy Gazebo simulations.

> [!TIP]
> `rmf_gym_lite` is best used for the following:
> - Help identify potential deadlocks in your RMF Map Building `.yaml` file
> - Allow ease of finetuning based on [recommended graph strategies](https://osrf.github.io/ros2multirobotbook/integration_nav-maps-strategies.html).

## **Build** :hammer:

```bash
git clone https://github.com/cardboardcode/rmf_gym_lite.git --depth 1 --single-branch main && cd rmf_gym_lite
```

```bash
bash scripts/1_pull_docker_compose.bash
```

## **Run** :rocket:

**Start** without `RViz`:

```bash
bash scripts/2_deploy_docker_compose.bash
```

**Start** with `RViz2`

```bash
bash scripts/2_deploy_docker_compose.bash -y
```

> To stop the deployment, run the command below:
> `bash scripts/3_stop_docker_compose.bash`

## **Scenario(s)**

### **triple_H**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/triple_h.gif)

### **simple_lift**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/simple_lift.gif)

### **simple_doors**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/simple_doors.gif)

### **delivery_queue**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/delivery_queue.gif)

### **lift_queue**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/lift_queue.gif)

### **narrow_corridor**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/narrow_corridor.gif)


## **Maintainer(s)**
- [cardboardcode](https://github.com/cardboardcode)
