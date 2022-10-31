#include <linux/module.h>
#include <linux/kernel.h>
#include <linux/leds.h>
#include <linux/slab.h>
#include <linux/gpio.h>
#include <linux/gpio/consumer.h>
#include <linux/platform_device.h>
#include <linux/of_gpio.h>

struct gpio_desc **gpioq = NULL;
uint32_t ngpio_q;
struct gpio_desc **gpiob = NULL;
uint32_t ngpio_b;
struct gpio_desc **gpioy = NULL;
uint32_t ngpio_y;


#define BUILD_GET_FUNC(name, gpio_desc)                    \
static ssize_t get_##name(struct device *dev, struct device_attribute *attr, char *buf)       \
{                                                           \
    int val = 0;                                            \
    if (gpio_desc == NULL)                                  \
        return -ENOENT;                                     \
    val = gpiod_get_value(gpio_desc);                       \
    return (sprintf(buf,"GPIO :%s Value: %d\n",#name,val)); \
}

#define BUILD_SET_FUNC(name, gpio_desc)            \
static ssize_t set_##name(struct device *dev, struct device_attribute *attr, const char *buf, size_t n) \
{                                               \
    int val = simple_strtol(buf, NULL, 10);     \
    if (gpio_desc == NULL)                      \
        return -ENOENT;                         \
    gpiod_set_value(gpio_desc, val);            \
    return n;                                   \
}

#define GPIO_DEVICE_ATTR_RW(name, num) \
static DEVICE_ATTR(name##num, S_IWUSR | S_IRUGO, get_##name##num, set_##name##num);

#define GPIO_DEVICE_ATTR_RO(name, num) \
static DEVICE_ATTR(name##num, S_IWUSR | S_IRUGO, get_##name##num, NULL);

BUILD_GET_FUNC(gpioq0, gpioq[0]);
BUILD_GET_FUNC(gpioq1, gpioq[1]);
BUILD_GET_FUNC(gpioq2, gpioq[2]);
//BUILD_GET_FUNC(gpioq3, gpioq[3]);
//BUILD_GET_FUNC(gpioq4, gpioq[4]);
BUILD_GET_FUNC(gpioq5, gpioq[5]);
BUILD_GET_FUNC(gpioq6, gpioq[6]);
BUILD_GET_FUNC(gpioq7, gpioq[7]);

BUILD_SET_FUNC(gpioq0, gpioq[0]);
BUILD_SET_FUNC(gpioq1, gpioq[1]);
BUILD_SET_FUNC(gpioq2, gpioq[2]);
//BUILD_SET_FUNC(gpioq3, gpioq[3]);
//BUILD_SET_FUNC(gpioq4, gpioq[4]);
//BUILD_SET_FUNC(gpioq5, gpioq[5]);
BUILD_SET_FUNC(gpioq6, gpioq[6]);
BUILD_SET_FUNC(gpioq7, gpioq[7]);

BUILD_GET_FUNC(gpiob1, gpiob[0]);
BUILD_GET_FUNC(gpiob2, gpiob[1]);
BUILD_GET_FUNC(gpiob3, gpiob[2]);
BUILD_GET_FUNC(gpiob4, gpiob[3]);
BUILD_GET_FUNC(gpiob6, gpiob[4]);

BUILD_SET_FUNC(gpiob3, gpiob[2]);

BUILD_GET_FUNC(gpioy0, gpioy[0]);
BUILD_GET_FUNC(gpioy1, gpioy[1]);
BUILD_GET_FUNC(gpioy2, gpioy[2]);
BUILD_GET_FUNC(gpioy3, gpioy[3]);

BUILD_SET_FUNC(gpioy1, gpioy[1]);
BUILD_SET_FUNC(gpioy2, gpioy[2]);
BUILD_SET_FUNC(gpioy3, gpioy[3]);

GPIO_DEVICE_ATTR_RW(gpioq, 0);
GPIO_DEVICE_ATTR_RW(gpioq, 1);
GPIO_DEVICE_ATTR_RW(gpioq, 2);
//GPIO_DEVICE_ATTR_RW(gpioq, 3);
//GPIO_DEVICE_ATTR_RW(gpioq, 4);
GPIO_DEVICE_ATTR_RO(gpioq, 5);
GPIO_DEVICE_ATTR_RW(gpioq, 6);
GPIO_DEVICE_ATTR_RW(gpioq, 7);


GPIO_DEVICE_ATTR_RO(gpiob, 1);
GPIO_DEVICE_ATTR_RO(gpiob, 2);
GPIO_DEVICE_ATTR_RW(gpiob, 3);
GPIO_DEVICE_ATTR_RO(gpiob, 4);
GPIO_DEVICE_ATTR_RO(gpiob, 6);

GPIO_DEVICE_ATTR_RO(gpioy, 0);
GPIO_DEVICE_ATTR_RW(gpioy, 1);
GPIO_DEVICE_ATTR_RW(gpioy, 2);
GPIO_DEVICE_ATTR_RW(gpioy, 3);


static struct attribute *gpioq_sys_entries[] = {
    &dev_attr_gpioq0.attr,
    &dev_attr_gpioq1.attr,
    &dev_attr_gpioq2.attr,
//    &dev_attr_gpioq3.attr,
//    &dev_attr_gpioq4.attr,
    &dev_attr_gpioq5.attr,
    &dev_attr_gpioq6.attr,
    &dev_attr_gpioq7.attr,
    NULL
};

static const struct attribute_group gpioq_attr_group = {
    .name = "gpioq",
    .attrs = gpioq_sys_entries,
};

static struct attribute *gpiob_sys_entries[] = {
    &dev_attr_gpiob1.attr,
    &dev_attr_gpiob2.attr,
    &dev_attr_gpiob3.attr,
    &dev_attr_gpiob4.attr,
    &dev_attr_gpiob6.attr,
    NULL
};

static const struct attribute_group gpiob_attr_group = {
    .name = "gpiob",
    .attrs = gpiob_sys_entries,
};

static struct attribute *gpioy_sys_entries[] = {
    &dev_attr_gpioy0.attr,
    &dev_attr_gpioy1.attr,
    &dev_attr_gpioy2.attr,
    &dev_attr_gpioy3.attr,
    NULL
};

static const struct attribute_group gpioy_attr_group = {
    .name = "gpioy",
    .attrs = gpioy_sys_entries,
};


static int lipari_gpio_probe(struct platform_device *pdev)
{
    int i;

    dev_info(&pdev->dev, "Driver for lipari BMC gpio");

    /*gpioq 0-7 */
    ngpio_q = gpiod_count(&pdev->dev, "gpioq");
    dev_info(&pdev->dev, "num of gpio line under q:%u\n", ngpio_q);
    if (ngpio_q > 0) {
        gpioq = devm_kcalloc(&pdev->dev, ngpio_q,
                    sizeof(struct gpio_desc *), GFP_KERNEL);
        if (gpioq != NULL) {
            for(i = 0; i < ngpio_q; i++) {
                if ((i == 0) || (i == 3)) {
                    gpioq[i] = devm_gpiod_get_index(&pdev->dev, "gpioq",
                                         i, GPIOD_OUT_LOW);
                } else if (i == 5) {
                    gpioq[i] = devm_gpiod_get_index(&pdev->dev, "gpioq",
                                    i, GPIOD_IN);
                } else {
                    gpioq[i] = devm_gpiod_get_index(&pdev->dev, "gpioq",
                                    i, GPIOD_OUT_HIGH);
                }
                if (IS_ERR(gpioq[i])) {
                    dev_err(&pdev->dev, "gpioq get failed at index:%d err:%ld",
                            i, PTR_ERR(gpioq[i]));
                    gpioq[i] = NULL;
                    return 0;
                }
            }
            sysfs_create_group(&(pdev->dev.kobj), &gpioq_attr_group);
        }
    }

    /*gpiob */
    ngpio_b = gpiod_count(&pdev->dev, "gpiob");
    dev_info(&pdev->dev, "num of gpio line under b:%u\n", ngpio_b);
    if (ngpio_b > 0) {
        gpiob = devm_kcalloc(&pdev->dev, ngpio_b,
                    sizeof(struct gpio_desc *), GFP_KERNEL);
        if (gpiob != NULL) {
            for(i = 0; i < ngpio_b; i++) {
                if (i == 3) {
                    gpiob[i] = devm_gpiod_get_index(&pdev->dev, "gpiob",
                                    i, GPIOD_OUT_HIGH);
                } else {
                    gpiob[i] = devm_gpiod_get_index(&pdev->dev, "gpiob",
                                    i, GPIOD_IN);
                }
                if (IS_ERR(gpiob[i])) {
                    dev_err(&pdev->dev, "gpiob get failed at index:%d err:%ld",
                            i, PTR_ERR(gpiob[i]));
                    gpiob[i] = NULL;
                    return 0;
                }
            }
            sysfs_create_group(&(pdev->dev.kobj), &gpiob_attr_group);
        }
    }

    /*gpioy */
    ngpio_y = gpiod_count(&pdev->dev, "gpioy");
    dev_info(&pdev->dev, "num of gpio line under y:%u\n", ngpio_y);
    if (ngpio_y > 0) {
        gpioy = devm_kcalloc(&pdev->dev, ngpio_y,
                    sizeof(struct gpio_desc *), GFP_KERNEL);
        if (gpioy != NULL) {
            for(i = 0; i < ngpio_y; i++) {
                if (i == 0) {
                    gpioy[i] = devm_gpiod_get_index(&pdev->dev, "gpioy",
                                    i, GPIOD_IN);
                } else {
                    gpioy[i] = devm_gpiod_get_index(&pdev->dev, "gpioy",
                                    i, GPIOD_OUT_LOW);
                }
                if (IS_ERR(gpioy[i])) {
                    dev_err(&pdev->dev, "gpioy get failed at index:%d err:%ld",
                            i, PTR_ERR(gpioy[i]));
                    gpioy[i] = NULL;
                    return 0;
                }
            }
            sysfs_create_group(&(pdev->dev.kobj), &gpioy_attr_group);
        }
    }
	dev_info(&pdev->dev, "initialized.\n");
    return 0;
}

static void free_gpio_resources (struct platform_device *pdev, int num_lines,
                                 struct gpio_desc **gpio,
                                 struct attribute_group *sysfs_attr_group)
{
    int i = 0;
    if (gpio) {
        for (i = 0; i < num_lines; i++) {
            if (gpio[i]) {
                devm_gpiod_put(&pdev->dev, gpio[i]);
            }
        }
        sysfs_remove_group(&(pdev->dev.kobj), sysfs_attr_group);
        devm_kfree(&(pdev->dev), gpio);
    }
}

static int lipari_gpio_remove(struct platform_device *pdev)
{
    int i = 0;

	dev_info(&pdev->dev, "exiting.\n");
    /* release gpios and sysfs entries */
    if (gpioq) {
        for (i = 0; i < ngpio_q; i++) {
            if (gpioq[i]) {
                devm_gpiod_put(&pdev->dev, gpioq[i]);
            }
        }
        sysfs_remove_group(&(pdev->dev.kobj), &gpioq_attr_group);
        devm_kfree(&(pdev->dev), gpioq);
    }
    if (gpiob) {
        for (i = 0; i < ngpio_b; i++) {
            if (gpiob[i]) {
                devm_gpiod_put(&pdev->dev, gpiob[i]);
            }
        }
        sysfs_remove_group(&(pdev->dev.kobj), &gpiob_attr_group);
        devm_kfree(&(pdev->dev), gpiob);
    }
    if (gpioy) {
        for (i = 0; i < ngpio_y; i++) {
            if (gpioy[i]) {
                devm_gpiod_put(&pdev->dev, gpioy[i]);
            }
        }
        sysfs_remove_group(&(pdev->dev.kobj), &gpioy_attr_group);
        devm_kfree(&(pdev->dev), gpioy);
    }
	return 0;
}

static const struct of_device_id of_lipari_gpio_match[] = {
	{ .compatible = "lipari_gpios" },
	{},
};

static struct platform_driver lipari_gpio_driver = {
	.driver = {
		.name	= "lipari_gpios",
		.owner	= THIS_MODULE,
		.of_match_table = of_lipari_gpio_match,
	},
	.probe		= lipari_gpio_probe,
	.remove		= lipari_gpio_remove,
};

module_platform_driver(lipari_gpio_driver);

MODULE_LICENSE("GPL");
MODULE_AUTHOR("Mushtaq Khan <Mushtaq.Khan@amd.com>");
MODULE_VERSION("1.0");
