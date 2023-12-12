import matplotlib.pyplot as plt

x = []
z = []

with open("data.log", "r") as f:
    for line in f:
        data = line.strip().split(",")
        if len(data) >= 2:
            x.append(float(data[0]))
            z.append(float(data[1]))
plt.plot(x)
plt.plot(z)
plt.xlabel('timesteps (500hz)')
plt.ylabel('meters')
plt.legend(["x", "z"])
plt.show()  # Display the plot