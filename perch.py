import logging
import sys
import time
from threading import Event

import cflib.crtp
from cflib.crazyflie import Crazyflie
from cflib.crazyflie.log import LogConfig
from cflib.crazyflie.syncCrazyflie import SyncCrazyflie
from cflib.positioning.motion_commander import MotionCommander
from cflib.positioning.position_hl_commander import PositionHlCommander
from cflib.utils import uri_helper

URI = uri_helper.uri_from_env(default='radio://0/40/2M/E7E7E7E7E7')
f = open("data.log", "a")
logging.basicConfig(level=logging.ERROR)
def console_incoming(console_text):
    print(console_text, end='')
    f.write(console_text.strip())

if __name__ == '__main__':
    cflib.crtp.init_drivers()

    with SyncCrazyflie(URI, cf=Crazyflie(rw_cache='./cache')) as scf:
        # scf.cf.console.receivedChar.add_callback(console_incoming)
        try:
            pc = PositionHlCommander(scf, controller=1)
            time.sleep(2)
            print("Taking Off...")
            pc.take_off(1.5)
            time.sleep(3)
            print("Switching to MPC...")
            scf.cf.param.set_value('stabilizer.controller', 5)
            time.sleep(1.002)
            scf.cf.commander.send_stop_setpoint()
            
            # print("Landing...")
            # scf.cf.param.set_value('stabilizer.controller', 1)
            # time.sleep(2)
            # pc.land()
            time.sleep(2)
        except KeyboardInterrupt:
            scf.cf.commander.send_stop_setpoint()
            f.close()