/*
* Copyright (C) 2014-2020 The OmniROM Project
*
* This program is free software: you can redistribute it and/or modify
* it under the terms of the GNU General Public License as published by
* the Free Software Foundation, either version 2 of the License, or
* (at your option) any later version.
*
* This program is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
* GNU General Public License for more details.
*
* You should have received a copy of the GNU General Public License
* along with this program. If not, see <http://www.gnu.org/licenses/>.
*
*/
package org.omnirom.device;

import android.content.Context;
import android.content.res.Resources;
import android.content.Intent;
import android.os.Bundle;
import android.os.RemoteException;
import android.os.ServiceManager;
import android.os.SystemProperties;
import androidx.preference.PreferenceFragment;
import androidx.preference.ListPreference;
import androidx.preference.Preference;
import androidx.preference.PreferenceScreen;
import android.provider.Settings;
import android.view.Display;
import android.view.Display.Mode;
import android.view.View;
import android.view.Surface;
import android.util.Log;

import java.util.ArrayList;
import java.util.List;

public class DeviceSettings extends PreferenceFragment implements
        Preference.OnPreferenceChangeListener {
    private static final String TAG = "DeviceSettings";
    private static final String KEY_ROTATION_LOCK = "rotation_lock";
    private static final String KEY_CPU_GOVERNOR = "cpu_governor";

    private static final String CPU_GOVERNOR_PROPERTY = "persist.vendor.cpufreq.governor";

    private static final String CPU_SYSFS_GOVERNORS = "/sys/devices/system/cpu/cpu2/cpufreq/scaling_available_governors";
    private static final String CPU_SYSFS_GOVERNOR = "/sys/devices/system/cpu/cpu2/cpufreq/scaling_governor";

    private IWindowManager mWindowManager;
    private ListPreference mRotationLock;
    private ListPreference mBootMode;
    private ListPreference mAudioCard;
    private ListPreference mCPUGovernor;
    private ListPreference mCPUMaxFreq;
    // 0 landscape 1 portrait
    private int mNativeOrientation;

    @Override
    public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
        setPreferencesFromResource(R.xml.main, rootKey);

        mRotationLock = (ListPreference) findPreference(KEY_ROTATION_LOCK);
        mRotationLock.setOnPreferenceChangeListener(this);
        mRotationLock.setSummary(mRotationLock.getEntry());

        mCPUGovernor = (ListPreference) findPreference(KEY_CPU_GOVERNOR);
        mCPUGovernor.setOnPreferenceChangeListener(this);
        setupGovernors();
        String governor = Utils.readLine(CPU_SYSFS_GOVERNOR);
        if (governor != null) {
            mCPUGovernor.setValue(governor);
            mCPUGovernor.setSummary(mCPUGovernor.getEntry());
        }

        Display.Mode mode = getActivity().getDisplay().getMode();
        mNativeOrientation = mode.getPhysicalWidth() > mode.getPhysicalHeight() ? 0 : 1;
    }

    @Override
    public boolean onPreferenceTreeClick(Preference preference) {
        return super.onPreferenceTreeClick(preference);
    }

    @Override
    public boolean onPreferenceChange(Preference preference, Object newValue) {
        if (preference == mRotationLock) {
            String value = (String) newValue;
            int rotationLockValue = Integer.valueOf(value);
            int accelerometerRotation = 0;
            int userRotation = 0;
            if (rotationLockValue == 0) {
                accelerometerRotation = 0;
                userRotation = Surface.ROTATION_0;
            } else if (rotationLockValue == 1) {
                accelerometerRotation = 1;
                userRotation = mNativeOrientation == 0 ? Surface.ROTATION_0 : Surface.ROTATION_270;
            } else if (rotationLockValue == 2) {
                accelerometerRotation = 1;
                userRotation = mNativeOrientation == 0 ? Surface.ROTATION_270 : Surface.ROTATION_0;
            } else if (rotationLockValue == 3) {
                accelerometerRotation = 1;
                userRotation = mNativeOrientation == 0 ? Surface.ROTATION_90 : Surface.ROTATION_180;
            } else if (rotationLockValue == 4) {
                accelerometerRotation = 1;
                userRotation = mNativeOrientation == 0 ? Surface.ROTATION_180 : Surface.ROTATION_90;
            }
            final ContentResolver res = getActivity().getContentResolver();
            Settings.System.putInt(res, Settings.System.ACCELEROMETER_ROTATION, accelerometerRotation);
            Settings.System.putInt(res, Settings.System.USER_ROTATION, userRotation);
            mRotationLock.setSummary(mRotationLock.getEntries()[rotationLockValue]);
        } else if (preference == mCPUGovernor) {
            String value = (String) newValue;
            SystemProperties.set(CPU_GOVERNOR_PROPERTY, value);
            mCPUGovernor.setSummary(value);
        }
        return true;
    }

    private void setupGovernors() {
        List<String> governors = Utils.readLineAsArray(CPU_SYSFS_GOVERNORS);
        if (governors != null) {
            String[] g = governors.toArray(new String[governors.size()]);
            mCPUGovernor.setEntryValues(g);
            mCPUGovernor.setEntries(g);
        } else {
            mCPUGovernor.setEnabled(false);
        }
    }
}
