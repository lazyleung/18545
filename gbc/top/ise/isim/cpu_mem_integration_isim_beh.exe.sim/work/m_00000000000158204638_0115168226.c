/**********************************************************************/
/*   ____  ____                                                       */
/*  /   /\/   /                                                       */
/* /___/  \  /                                                        */
/* \   \   \/                                                       */
/*  \   \        Copyright (c) 2003-2009 Xilinx, Inc.                */
/*  /   /          All Right Reserved.                                 */
/* /---/   /\                                                         */
/* \   \  /  \                                                      */
/*  \___\/\___\                                                    */
/***********************************************************************/

/* This file is designed for use with ISim build 0x7708f090 */

#define XSI_HIDE_SYMBOL_SPEC true
#include "xsi.h"
#include <memory.h>
#ifdef __GNUC__
#include <stdlib.h>
#else
#include <malloc.h>
#define alloca _alloca
#endif
static const char *ng0 = "C:/Users/ash/Documents/18545/gbc/memory/bram_sim/bram_sim.v";
static const char *ng1 = "oam_dma_test.dat";



static void Always_34_0(char *t0)
{
    char t12[8];
    char t13[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    unsigned int t6;
    unsigned int t7;
    unsigned int t8;
    unsigned int t9;
    unsigned int t10;
    char *t11;
    char *t14;
    char *t15;
    char *t16;
    char *t17;
    char *t18;
    char *t19;
    char *t20;
    unsigned int t21;
    int t22;
    char *t23;
    unsigned int t24;
    int t25;
    int t26;
    unsigned int t27;
    unsigned int t28;
    int t29;
    int t30;

LAB0:    t1 = (t0 + 3944U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(34, ng0);
    t2 = (t0 + 4512);
    *((int *)t2) = 1;
    t3 = (t0 + 3976);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(34, ng0);

LAB5:    xsi_set_current_line(35, ng0);
    t4 = (t0 + 1344U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(37, ng0);

LAB10:    xsi_set_current_line(38, ng0);
    t2 = (t0 + 1504U);
    t3 = *((char **)t2);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB11;

LAB12:
LAB13:    xsi_set_current_line(40, ng0);
    t2 = (t0 + 1984U);
    t3 = *((char **)t2);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB16;

LAB17:
LAB18:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(35, ng0);

LAB9:    xsi_set_current_line(36, ng0);
    t11 = (t0 + 3024);
    xsi_vlogfile_readmemh(ng1, 0, t11, 0, 0, 0, 0);
    goto LAB8;

LAB11:    xsi_set_current_line(39, ng0);
    t4 = (t0 + 1824U);
    t5 = *((char **)t4);
    t4 = (t0 + 3024);
    t11 = (t0 + 3024);
    t14 = (t11 + 72U);
    t15 = *((char **)t14);
    t16 = (t0 + 3024);
    t17 = (t16 + 64U);
    t18 = *((char **)t17);
    t19 = (t0 + 1664U);
    t20 = *((char **)t19);
    xsi_vlog_generic_convert_array_indices(t12, t13, t15, t18, 2, 1, t20, 15, 2);
    t19 = (t12 + 4);
    t21 = *((unsigned int *)t19);
    t22 = (!(t21));
    t23 = (t13 + 4);
    t24 = *((unsigned int *)t23);
    t25 = (!(t24));
    t26 = (t22 && t25);
    if (t26 == 1)
        goto LAB14;

LAB15:    goto LAB13;

LAB14:    t27 = *((unsigned int *)t12);
    t28 = *((unsigned int *)t13);
    t29 = (t27 - t28);
    t30 = (t29 + 1);
    xsi_vlogvar_wait_assign_value(t4, t5, 0, *((unsigned int *)t13), t30, 0LL);
    goto LAB15;

LAB16:    xsi_set_current_line(41, ng0);
    t4 = (t0 + 2304U);
    t5 = *((char **)t4);
    t4 = (t0 + 3024);
    t11 = (t0 + 3024);
    t14 = (t11 + 72U);
    t15 = *((char **)t14);
    t16 = (t0 + 3024);
    t17 = (t16 + 64U);
    t18 = *((char **)t17);
    t19 = (t0 + 2144U);
    t20 = *((char **)t19);
    xsi_vlog_generic_convert_array_indices(t12, t13, t15, t18, 2, 1, t20, 15, 2);
    t19 = (t12 + 4);
    t21 = *((unsigned int *)t19);
    t22 = (!(t21));
    t23 = (t13 + 4);
    t24 = *((unsigned int *)t23);
    t25 = (!(t24));
    t26 = (t22 && t25);
    if (t26 == 1)
        goto LAB19;

LAB20:    goto LAB18;

LAB19:    t27 = *((unsigned int *)t12);
    t28 = *((unsigned int *)t13);
    t29 = (t27 - t28);
    t30 = (t29 + 1);
    xsi_vlogvar_wait_assign_value(t4, t5, 0, *((unsigned int *)t13), t30, 0LL);
    goto LAB20;

}

static void Always_45_1(char *t0)
{
    char t7[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t6;
    char *t8;
    char *t9;
    char *t10;
    char *t11;
    char *t12;
    char *t13;
    char *t14;
    char *t15;

LAB0:    t1 = (t0 + 4192U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(45, ng0);
    t2 = (t0 + 4528);
    *((int *)t2) = 1;
    t3 = (t0 + 4224);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(45, ng0);

LAB5:    xsi_set_current_line(46, ng0);
    t4 = (t0 + 3024);
    t5 = (t4 + 56U);
    t6 = *((char **)t5);
    t8 = (t0 + 3024);
    t9 = (t8 + 72U);
    t10 = *((char **)t9);
    t11 = (t0 + 3024);
    t12 = (t11 + 64U);
    t13 = *((char **)t12);
    t14 = (t0 + 1664U);
    t15 = *((char **)t14);
    xsi_vlog_generic_get_array_select_value(t7, 8, t6, t10, t13, 2, 1, t15, 15, 2);
    t14 = (t0 + 2704);
    xsi_vlogvar_wait_assign_value(t14, t7, 0, 0, 8, 0LL);
    xsi_set_current_line(47, ng0);
    t2 = (t0 + 3024);
    t3 = (t2 + 56U);
    t4 = *((char **)t3);
    t5 = (t0 + 3024);
    t6 = (t5 + 72U);
    t8 = *((char **)t6);
    t9 = (t0 + 3024);
    t10 = (t9 + 64U);
    t11 = *((char **)t10);
    t12 = (t0 + 2144U);
    t13 = *((char **)t12);
    xsi_vlog_generic_get_array_select_value(t7, 8, t4, t8, t11, 2, 1, t13, 15, 2);
    t12 = (t0 + 2864);
    xsi_vlogvar_wait_assign_value(t12, t7, 0, 0, 8, 0LL);
    goto LAB2;

}


extern void work_m_00000000000158204638_0115168226_init()
{
	static char *pe[] = {(void *)Always_34_0,(void *)Always_45_1};
	xsi_register_didat("work_m_00000000000158204638_0115168226", "isim/cpu_mem_integration_isim_beh.exe.sim/work/m_00000000000158204638_0115168226.didat");
	xsi_register_executes(pe);
}
