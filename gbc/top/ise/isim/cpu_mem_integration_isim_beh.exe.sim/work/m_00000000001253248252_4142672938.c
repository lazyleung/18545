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
static unsigned int ng1[] = {31U, 0U};
static unsigned int ng2[] = {0U, 0U};
static unsigned int ng3[] = {8U, 0U};
static unsigned int ng4[] = {1U, 0U};
static unsigned int ng5[] = {2U, 0U};
static unsigned int ng6[] = {9U, 0U};
static unsigned int ng7[] = {3U, 0U};
static unsigned int ng8[] = {4U, 0U};
static unsigned int ng9[] = {10U, 0U};
static unsigned int ng10[] = {5U, 0U};
static unsigned int ng11[] = {11U, 0U};
static unsigned int ng12[] = {16U, 0U};
static unsigned int ng13[] = {17U, 0U};
static unsigned int ng14[] = {18U, 0U};
static unsigned int ng15[] = {19U, 0U};



static void Always_493_0(char *t0)
{
    char t6[8];
    char t28[8];
    char *t1;
    char *t2;
    char *t3;
    char *t4;
    char *t5;
    char *t7;
    char *t8;
    unsigned int t9;
    unsigned int t10;
    unsigned int t11;
    unsigned int t12;
    unsigned int t13;
    unsigned int t14;
    unsigned int t15;
    unsigned int t16;
    unsigned int t17;
    unsigned int t18;
    unsigned int t19;
    unsigned int t20;
    char *t21;
    char *t22;
    unsigned int t23;
    unsigned int t24;
    unsigned int t25;
    unsigned int t26;
    unsigned int t27;
    char *t29;
    char *t30;
    unsigned int t31;
    unsigned int t32;
    unsigned int t33;
    unsigned int t34;
    unsigned int t35;
    char *t36;
    char *t37;
    char *t38;
    unsigned int t39;
    unsigned int t40;
    unsigned int t41;
    unsigned int t42;
    unsigned int t43;
    unsigned int t44;
    unsigned int t45;
    unsigned int t46;
    char *t47;
    unsigned int t48;
    unsigned int t49;
    unsigned int t50;
    unsigned int t51;
    unsigned int t52;
    char *t53;
    char *t54;
    int t55;
    char *t56;
    char *t57;

LAB0:    t1 = (t0 + 3008U);
    t2 = *((char **)t1);
    if (t2 == 0)
        goto LAB2;

LAB3:    goto *t2;

LAB2:    xsi_set_current_line(493, ng0);
    t2 = (t0 + 3328);
    *((int *)t2) = 1;
    t3 = (t0 + 3040);
    *((char **)t3) = t2;
    *((char **)t1) = &&LAB4;

LAB1:    return;
LAB4:    xsi_set_current_line(493, ng0);

LAB5:    xsi_set_current_line(494, ng0);
    t4 = (t0 + 1048U);
    t5 = *((char **)t4);
    t4 = ((char*)((ng1)));
    memset(t6, 0, 8);
    t7 = (t5 + 4);
    t8 = (t4 + 4);
    t9 = *((unsigned int *)t5);
    t10 = *((unsigned int *)t4);
    t11 = (t9 ^ t10);
    t12 = *((unsigned int *)t7);
    t13 = *((unsigned int *)t8);
    t14 = (t12 ^ t13);
    t15 = (t11 | t14);
    t16 = *((unsigned int *)t7);
    t17 = *((unsigned int *)t8);
    t18 = (t16 | t17);
    t19 = (~(t18));
    t20 = (t15 & t19);
    if (t20 != 0)
        goto LAB9;

LAB6:    if (t18 != 0)
        goto LAB8;

LAB7:    *((unsigned int *)t6) = 1;

LAB9:    t22 = (t6 + 4);
    t23 = *((unsigned int *)t22);
    t24 = (~(t23));
    t25 = *((unsigned int *)t6);
    t26 = (t25 & t24);
    t27 = (t26 != 0);
    if (t27 > 0)
        goto LAB10;

LAB11:    xsi_set_current_line(530, ng0);

LAB85:    xsi_set_current_line(531, ng0);
    t2 = (t0 + 1048U);
    t4 = *((char **)t2);
    t2 = (t0 + 2088);
    xsi_vlogvar_assign_value(t2, t4, 0, 0, 5);

LAB12:    goto LAB2;

LAB8:    t21 = (t6 + 4);
    *((unsigned int *)t6) = 1;
    *((unsigned int *)t21) = 1;
    goto LAB9;

LAB10:    xsi_set_current_line(494, ng0);

LAB13:    xsi_set_current_line(495, ng0);
    t29 = (t0 + 1368U);
    t30 = *((char **)t29);
    memset(t28, 0, 8);
    t29 = (t30 + 4);
    t31 = *((unsigned int *)t29);
    t32 = (~(t31));
    t33 = *((unsigned int *)t30);
    t34 = (t33 & t32);
    t35 = (t34 & 1U);
    if (t35 != 0)
        goto LAB17;

LAB15:    if (*((unsigned int *)t29) == 0)
        goto LAB14;

LAB16:    t36 = (t28 + 4);
    *((unsigned int *)t28) = 1;
    *((unsigned int *)t36) = 1;

LAB17:    t37 = (t28 + 4);
    t38 = (t30 + 4);
    t39 = *((unsigned int *)t30);
    t40 = (~(t39));
    *((unsigned int *)t28) = t40;
    *((unsigned int *)t37) = 0;
    if (*((unsigned int *)t38) != 0)
        goto LAB19;

LAB18:    t45 = *((unsigned int *)t28);
    *((unsigned int *)t28) = (t45 & 1U);
    t46 = *((unsigned int *)t37);
    *((unsigned int *)t37) = (t46 & 1U);
    t47 = (t28 + 4);
    t48 = *((unsigned int *)t47);
    t49 = (~(t48));
    t50 = *((unsigned int *)t28);
    t51 = (t50 & t49);
    t52 = (t51 != 0);
    if (t52 > 0)
        goto LAB20;

LAB21:    xsi_set_current_line(505, ng0);
    t2 = (t0 + 1688U);
    t3 = *((char **)t2);
    t2 = (t3 + 4);
    t9 = *((unsigned int *)t2);
    t10 = (~(t9));
    t11 = *((unsigned int *)t3);
    t12 = (t11 & t10);
    t13 = (t12 != 0);
    if (t13 > 0)
        goto LAB40;

LAB41:    xsi_set_current_line(513, ng0);
    t2 = (t0 + 1528U);
    t3 = *((char **)t2);
    t2 = (t3 + 4);
    t9 = *((unsigned int *)t2);
    t10 = (~(t9));
    t11 = *((unsigned int *)t3);
    t12 = (t11 & t10);
    t13 = (t12 != 0);
    if (t13 > 0)
        goto LAB56;

LAB57:    xsi_set_current_line(521, ng0);

LAB72:    xsi_set_current_line(522, ng0);
    t2 = (t0 + 1208U);
    t3 = *((char **)t2);

LAB73:    t2 = ((char*)((ng2)));
    t55 = xsi_vlog_unsigned_case_compare(t3, 3, t2, 3);
    if (t55 == 1)
        goto LAB74;

LAB75:    t2 = ((char*)((ng4)));
    t55 = xsi_vlog_unsigned_case_compare(t3, 3, t2, 3);
    if (t55 == 1)
        goto LAB76;

LAB77:    t2 = ((char*)((ng5)));
    t55 = xsi_vlog_unsigned_case_compare(t3, 3, t2, 3);
    if (t55 == 1)
        goto LAB78;

LAB79:    t2 = ((char*)((ng7)));
    t55 = xsi_vlog_unsigned_case_compare(t3, 3, t2, 3);
    if (t55 == 1)
        goto LAB80;

LAB81:
LAB83:
LAB82:    xsi_set_current_line(527, ng0);
    t2 = ((char*)((ng3)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t2, 0, 0, 5);

LAB84:
LAB58:
LAB42:
LAB22:    goto LAB12;

LAB14:    *((unsigned int *)t28) = 1;
    goto LAB17;

LAB19:    t41 = *((unsigned int *)t28);
    t42 = *((unsigned int *)t38);
    *((unsigned int *)t28) = (t41 | t42);
    t43 = *((unsigned int *)t37);
    t44 = *((unsigned int *)t38);
    *((unsigned int *)t37) = (t43 | t44);
    goto LAB18;

LAB20:    xsi_set_current_line(495, ng0);

LAB23:    xsi_set_current_line(496, ng0);
    t53 = (t0 + 1208U);
    t54 = *((char **)t53);

LAB24:    t53 = ((char*)((ng2)));
    t55 = xsi_vlog_unsigned_case_compare(t54, 3, t53, 3);
    if (t55 == 1)
        goto LAB25;

LAB26:    t2 = ((char*)((ng4)));
    t55 = xsi_vlog_unsigned_case_compare(t54, 3, t2, 3);
    if (t55 == 1)
        goto LAB27;

LAB28:    t2 = ((char*)((ng5)));
    t55 = xsi_vlog_unsigned_case_compare(t54, 3, t2, 3);
    if (t55 == 1)
        goto LAB29;

LAB30:    t2 = ((char*)((ng7)));
    t55 = xsi_vlog_unsigned_case_compare(t54, 3, t2, 3);
    if (t55 == 1)
        goto LAB31;

LAB32:    t2 = ((char*)((ng8)));
    t55 = xsi_vlog_unsigned_case_compare(t54, 3, t2, 3);
    if (t55 == 1)
        goto LAB33;

LAB34:    t2 = ((char*)((ng10)));
    t55 = xsi_vlog_unsigned_case_compare(t54, 3, t2, 3);
    if (t55 == 1)
        goto LAB35;

LAB36:
LAB38:
LAB37:    xsi_set_current_line(503, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 2088);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 5);

LAB39:    goto LAB22;

LAB25:    xsi_set_current_line(497, ng0);
    t56 = ((char*)((ng3)));
    t57 = (t0 + 2088);
    xsi_vlogvar_assign_value(t57, t56, 0, 0, 5);
    goto LAB39;

LAB27:    xsi_set_current_line(498, ng0);
    t3 = ((char*)((ng2)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB39;

LAB29:    xsi_set_current_line(499, ng0);
    t3 = ((char*)((ng6)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB39;

LAB31:    xsi_set_current_line(500, ng0);
    t3 = ((char*)((ng4)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB39;

LAB33:    xsi_set_current_line(501, ng0);
    t3 = ((char*)((ng9)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB39;

LAB35:    xsi_set_current_line(502, ng0);
    t3 = ((char*)((ng5)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB39;

LAB40:    xsi_set_current_line(505, ng0);

LAB43:    xsi_set_current_line(506, ng0);
    t4 = (t0 + 1208U);
    t5 = *((char **)t4);

LAB44:    t4 = ((char*)((ng2)));
    t55 = xsi_vlog_unsigned_case_compare(t5, 3, t4, 3);
    if (t55 == 1)
        goto LAB45;

LAB46:    t2 = ((char*)((ng4)));
    t55 = xsi_vlog_unsigned_case_compare(t5, 3, t2, 3);
    if (t55 == 1)
        goto LAB47;

LAB48:    t2 = ((char*)((ng5)));
    t55 = xsi_vlog_unsigned_case_compare(t5, 3, t2, 3);
    if (t55 == 1)
        goto LAB49;

LAB50:    t2 = ((char*)((ng7)));
    t55 = xsi_vlog_unsigned_case_compare(t5, 3, t2, 3);
    if (t55 == 1)
        goto LAB51;

LAB52:
LAB54:
LAB53:    xsi_set_current_line(511, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 2088);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 5);

LAB55:    goto LAB42;

LAB45:    xsi_set_current_line(507, ng0);
    t7 = ((char*)((ng3)));
    t8 = (t0 + 2088);
    xsi_vlogvar_assign_value(t8, t7, 0, 0, 5);
    goto LAB55;

LAB47:    xsi_set_current_line(508, ng0);
    t3 = ((char*)((ng6)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB55;

LAB49:    xsi_set_current_line(509, ng0);
    t3 = ((char*)((ng9)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB55;

LAB51:    xsi_set_current_line(510, ng0);
    t3 = ((char*)((ng11)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB55;

LAB56:    xsi_set_current_line(513, ng0);

LAB59:    xsi_set_current_line(514, ng0);
    t4 = (t0 + 1208U);
    t7 = *((char **)t4);

LAB60:    t4 = ((char*)((ng2)));
    t55 = xsi_vlog_unsigned_case_compare(t7, 3, t4, 3);
    if (t55 == 1)
        goto LAB61;

LAB62:    t2 = ((char*)((ng4)));
    t55 = xsi_vlog_unsigned_case_compare(t7, 3, t2, 3);
    if (t55 == 1)
        goto LAB63;

LAB64:    t2 = ((char*)((ng5)));
    t55 = xsi_vlog_unsigned_case_compare(t7, 3, t2, 3);
    if (t55 == 1)
        goto LAB65;

LAB66:    t2 = ((char*)((ng7)));
    t55 = xsi_vlog_unsigned_case_compare(t7, 3, t2, 3);
    if (t55 == 1)
        goto LAB67;

LAB68:
LAB70:
LAB69:    xsi_set_current_line(519, ng0);
    t2 = ((char*)((ng3)));
    t3 = (t0 + 2088);
    xsi_vlogvar_assign_value(t3, t2, 0, 0, 5);

LAB71:    goto LAB58;

LAB61:    xsi_set_current_line(515, ng0);
    t8 = ((char*)((ng2)));
    t21 = (t0 + 2088);
    xsi_vlogvar_assign_value(t21, t8, 0, 0, 5);
    goto LAB71;

LAB63:    xsi_set_current_line(516, ng0);
    t3 = ((char*)((ng4)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB71;

LAB65:    xsi_set_current_line(517, ng0);
    t3 = ((char*)((ng5)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB71;

LAB67:    xsi_set_current_line(518, ng0);
    t3 = ((char*)((ng7)));
    t4 = (t0 + 2088);
    xsi_vlogvar_assign_value(t4, t3, 0, 0, 5);
    goto LAB71;

LAB74:    xsi_set_current_line(523, ng0);
    t4 = ((char*)((ng12)));
    t8 = (t0 + 2088);
    xsi_vlogvar_assign_value(t8, t4, 0, 0, 5);
    goto LAB84;

LAB76:    xsi_set_current_line(524, ng0);
    t4 = ((char*)((ng13)));
    t8 = (t0 + 2088);
    xsi_vlogvar_assign_value(t8, t4, 0, 0, 5);
    goto LAB84;

LAB78:    xsi_set_current_line(525, ng0);
    t4 = ((char*)((ng14)));
    t8 = (t0 + 2088);
    xsi_vlogvar_assign_value(t8, t4, 0, 0, 5);
    goto LAB84;

LAB80:    xsi_set_current_line(526, ng0);
    t4 = ((char*)((ng15)));
    t8 = (t0 + 2088);
    xsi_vlogvar_assign_value(t8, t4, 0, 0, 5);
    goto LAB84;

}


extern void work_m_00000000001253248252_4142672938_init()
{
	static char *pe[] = {(void *)Always_493_0};
	xsi_register_didat("work_m_00000000001253248252_4142672938", "isim/cpu_mem_integration_isim_beh.exe.sim/work/m_00000000001253248252_4142672938.didat");
	xsi_register_executes(pe);
}
