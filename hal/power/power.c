/*
 * Copyright (C) 2017 The Android Open Source Project
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
#define LOG_TAG "android.hardware.power@1.1-service.yukawa"

#include <errno.h>
#include <string.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <time.h>
#include <pthread.h>
#include <unistd.h>

#include <utils/Log.h>

#include <hardware/hardware.h>
#include <hardware/power.h>

#include "utils.h"

#define UNUSED_ARGUMENT __attribute((unused))

// in seconds
#define PERFORMANCE_BOOT_TIMEOUT 2

static pthread_t tid = -1;
static char min_freq_little[1024];
static char max_freq_little[1024];
static char min_freq_big[1024];
static char max_freq_big[1024];
static int DEBUG = 0;
static pthread_mutex_t lock;

static void *performance_boost_thread(UNUSED_ARGUMENT void *data)
{
    get_scaling_max_freq(SCALING_MAX_FREQ_LITTLE, max_freq_little, 1024);
    get_scaling_min_freq(SCALING_MIN_FREQ_LITTLE, min_freq_little, 1024);

    if (DEBUG) ALOGD("performance_boost little start %s -> %s", min_freq_little, max_freq_little);
    sysfs_write(SCALING_MIN_FREQ_LITTLE, max_freq_little);

    get_scaling_max_freq(SCALING_MAX_FREQ_BIG, max_freq_big, 1024);
    get_scaling_min_freq(SCALING_MIN_FREQ_BIG, min_freq_big, 1024);

    if (DEBUG) ALOGD("performance_boost big start %s -> %s", min_freq_big, max_freq_big);
    sysfs_write(SCALING_MIN_FREQ_BIG, max_freq_big);

    sleep(PERFORMANCE_BOOT_TIMEOUT);
    
    sysfs_write(SCALING_MIN_FREQ_LITTLE, min_freq_little);
    sysfs_write(SCALING_MIN_FREQ_BIG, min_freq_big);

    if (DEBUG) ALOGD("performance_boost little end %s -> %s", max_freq_little, min_freq_little);
    if (DEBUG) ALOGD("performance_boost big end %s -> %s", max_freq_big, min_freq_big);

    tid = -1;
    return NULL;
}

static int start_performance_boost()
{
    if (tid != -1) {
        return 0;
    }

    return pthread_create(&tid, NULL, performance_boost_thread, NULL);
}

void power_init(void)
{
    pthread_mutex_init(&lock, NULL);
}

void power_hint(power_hint_t hint, UNUSED_ARGUMENT void *data)
{
    pthread_mutex_lock(&lock);
    if (DEBUG) ALOGD("power_hint hint %d", hint);

    switch (hint) {
     case POWER_HINT_INTERACTION:
        start_performance_boost();
        break;

    case POWER_HINT_VSYNC:
        break;

    case POWER_HINT_LOW_POWER:
        break;

    default:
        break;
    }
    pthread_mutex_unlock(&lock);
}

