## **What Is This?**

This is a collection of **lightweight simulated RMF deployments** you can run locally on your workstation to test RMF task workflows and deconflictions.

These deployments uses [invisibot](https://github.com/cardboardcode/invisibot/tree/devel/gary) and [fleet_adapter_invisibot](https://github.com/cardboardcode/fleet_adapter_invisibot) in order to skip setting up a physical robot as well as avoid using computationally-heavy Gazebo simulations.

## **Build**

```bash
git clone https://github.com/cardboardcode/rmf_gym_lite.git --depth 1 --single-branch main
```

```bash
docker compose -f examples/simple_lift/docker-compose.yaml build
```

## **Run**

```bash
bash scripts/1_run_triple_h_scenario.bash
```

## **Verify**

### **triple_H**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/triple_h.png)

### **simple_deconfliction**
![](https://raw.githubusercontent.com/cardboardcode/rmf_gym_lite/media/assets/simple_deconfliction.png)

## **Maintainer(s)**
- [cardboardcode](https://github.com/cardboardcode)
