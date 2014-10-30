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
static const char *ng0 = "C:/Users/ash/Documents/18545/gbc/cpu/src/cpu.v";



static void Always_586_0(char *t0)
{
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
    char *t12;

LAB0:    t1 = (t0 + 3120U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(586, ng0);
    t2 = (t0 + 3440);
    *((int *)t2) = 1;
    t3 = (t0 + 3152);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(586, ng0);

LAB5:    xsi_set_current_line(587, ng0);
    t4 = (t0 + 1800U);
    t5 = *((char **)t4);
    t4 = (t5 + 4);
    t6 = *((unsigned int *)t4);
    t7 = (~(t6));
    t8 = *((unsigned int *)t5);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB6;

LAB7:    xsi_set_current_line(590, ng0);
    t2 = (t0 + 1480U);
    t3 = *((char **)t2);
    t2 = (t3 + 4);
    t6 = *((unsigned int *)t2);
    t7 = (~(t6));
    t8 = *((unsigned int *)t3);
    t9 = (t8 & t7);
    t10 = (t9 != 0);
    if (t10 > 0)
        goto LAB10;

LAB11:
LAB12:
LAB8:    goto LAB2;

LAB6:    xsi_set_current_line(587, ng0);

LAB9:    xsi_set_current_line(588, ng0);
    t11 = (t0 + 608);
    t12 = *((char **)t11);
    t11 = (t0 + 2200);
    xsi_vlogvar_wait_assign_value(t11, t12, 0, 0, 8, 0LL);
    goto LAB8;

LAB10:    xsi_set_current_line(590, ng0);

LAB13:    xsi_set_current_line(591, ng0);
    t4 = (t0 + 1320U);
    t5 = *((char **)t4);
    t4 = (t0 + 2200);
    xsi_vlogvar_wait_assign_value(t4, t5, 0, 0, 8, 0LL);
    goto LAB12;

}


extern void work_m_00000000000091283007_3913188552_init()
{
	static char *pe[] = {(void *)Always_586_0};
	xsi_register_didat("work_m_00000000000091283007_3913188552", "isim/cpu_mem_integration_isim_beh.exe.sim/work/m_00000000000091283007_3913188552.didat");
	xsi_register_executes(pe);
}
