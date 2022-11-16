/* SPDX-License-Identifier: Apache-2.0 OR GPL-2.0-or-later */
/* AMD MCTP command test tools
 *
 * @file amd-mctp-tool.c
 * @brief Example application to test the MCTP protocol.
 * This application does the following:
 *    - Allows to send any MCTP raw commands and to receive the response,
 *    - Prints the Response data in human readable format.
 *    - Prints the  MCTP Response payload in raw format when --verbose enabled
 *    - Allows to run the built-in Dicscovery  process,
 *    - Allows to run the built-in MCTP command tests.
 *    - e.g.  - amd-mctp-tool -D                    // Run the MCTP Discovery to discover Endpoint
 *            - amd-mctp-tool -e 0x0a -T            // Run the built-in mctp commands test
 *            - amd-mctp-tool -e 0x0a -c 0x02       // Send 'Get EID' command to destination EID 0x0a
 *            - amd-mctp-tool -e 0x0a -c 0x02 -v    // print the Response payload dump
 */

#include <poll.h>
#include <stdio.h>
#include <unistd.h>
#include <getopt.h>
#include <stdlib.h>
#include <time.h>

#include "libmctp-astpcie.h"
#include "libmctp-cmds.h"
#include "amd-mctp-tool.h"

/* Globle variables */
static bool verbose = false;

/* Print  Completion code status */
static void print_completion_code(uint8_t code)
{
    if (code == MCTP_CTRL_CC_SUCCESS) {
        printf("Completion code            : SUCCESS\n");
    }
    else if (code == MCTP_CTRL_CC_ERROR)
        printf("Completion code            : ERROR\n");
    else if (code == MCTP_CTRL_CC_ERROR_INVALID_DATA)
        printf("Completion code            : ERROR_INVALID_DATA\n");
    else if (code == MCTP_CTRL_CC_ERROR_INVALID_LENGTH)
        printf("Completion code            : ERROR_INVALID_LENGTH\n");
    else if (code == MCTP_CTRL_CC_ERROR_NOT_READY)
        printf("Completion code            : ERROR_NOT_READY\n");
    else if (code == MCTP_CTRL_CC_ERROR_UNSUPPORTED_CMD)
        printf("Completion code            : ERROR_UNSUPPORTED_CMD\n");
    else
        printf("Completion code            : COMMAND_SPECIFIC\n");

    return;
}

/* Print MCTP Message Payload */
static void dump_payload_data(uint8_t *data)
{
    if ( verbose ) {
        printf("MCTP Message payload       : ");
        for (int i = 0; i < MCTP_RESP_PAYLOAD_LEN; i++){
            printf("%02X ", data[i]);
            if ( (i%8==7) && (i < MCTP_RESP_PAYLOAD_LEN-1))
                printf("\n                           : ");
        }
        printf("\n");
    }
    return;
}

/* Print Resolve UUID response */
static void print_resolve_uuid_data(uint8_t *data)
{
    struct resolve_uuid_data * uudata = (struct resolve_uuid_data *)data;
    printf("Bridge Endpoint ID         : 0x%02X\n", uudata->bridge_eid );
    printf("Physical Address           : 0x%04X\n", uudata->phy_addres );

    return;
}

/* Print Query Supported Interfaces response */
static void print_query_supported_interfaces_data(uint8_t *data)
{
    struct query_supported_interfaces_Res_data *ifdata = (struct query_supported_interfaces_Res_data*)data;
    struct eid_interface *eiptr = &(ifdata->eid_intf);

    printf("Supported Interface count  : 0x%d\n", ifdata->interface_count );
    for ( int i=0; i < ifdata->interface_count; i++) {
        printf("Interface Type             : 0x%d\n", eiptr->intf_type );
        printf("Interface EID              : 0x%d\n", eiptr->intf_eid );
        eiptr++;
    }

    return;
}

/* Print Transmit rate limit response */
static void print_tx_rate_limit_data(uint8_t *data)
{
    struct tx_rate_limit_Res_data *rldata = (struct tx_rate_limit_Res_data *)data;

    printf("Present burst settings     : 0x%d\n", rldata->curr_tx_burst_size );
    printf("Present TX rate limit set  : 0x%d\n", rldata->curr_tx_rate_limit );

    return;
}

/* Print Query rate limit response */
static void print_query_rate_limit_data(uint8_t *data)
{
    struct query_rate_limit_data *rate_data = (struct query_rate_limit_data *)data;

    printf("Receive buffer size        : 0x%d\n", rate_data->recv_buff_size );
    printf("Max Receive rate limit     : 0x%d\n", rate_data->max_recv_rate_limit );
    printf("Max Supported Tx rate limit: 0x%d\n", rate_data->max_support_limit );
    printf("Min Supported Tx rate limit: 0x%d\n", rate_data->min_support_limit );
    printf("Max Supported burst size   : 0x%d\n", rate_data->max_burst_size );
    printf("Present burst settings     : 0x%d\n", rate_data->recv_buff_size );
    printf("Present TX rate limit set  : 0x%d\n", rate_data->curr_bust_set );
    printf("Tx Rate limiter capabilites: 0x%0x2X\n", rate_data->tx_rate_limt_cap );

    return;
}

/* Print Query Hop response */
static void print_query_hop_data(uint8_t *data)
{
    struct query_hop_data *qhdata = (struct query_hop_data *)data;

    printf("EID of next bridge         : 0x%02x\n", qhdata->eid_next_bridge );
    printf("Message Type               : 0x%02x\n", qhdata->msg_type );
    printf("Max incomomming unit size  : %d\n", (MCTP_QUERY_HOP_BASE_UNIT_SIZE + (qhdata->in_trans_unit_size * MCTP_QUERY_HOP_INCREMENT_SIZE)) );
    printf("Max outgoing unit size     : %d\n", (MCTP_QUERY_HOP_BASE_UNIT_SIZE + (qhdata->out_trans_unit_size * MCTP_QUERY_HOP_INCREMENT_SIZE)) );

    return;
}

/* Print Resolve Endpoint ID response */
static void print_resolve_eid_data(uint8_t *data)
{
    struct resolve_eid_data *reid = ( struct resolve_eid_data *)data;

    if ( reid->bridge_eid == MCTP_MPIO_BRIDGE_EID )
        printf("Bridge Ednpint ID          : 0x%02x, No need to resolve EID\n", reid->bridge_eid);
    else {
        printf("Bridge Ednpint ID          : 0x%02x\n", reid->bridge_eid);
        printf("Physicla Address           : 0x%04X\n", reid->phy_addr);
    }
    return;
}

/* Print Allocate ID response */
static void print_allocate_id_data(uint8_t *data)
{
    struct alloc_eid_data *aeid = (struct alloc_eid_data *)data;

    if ( aeid->alloc_status == ALLEOCATE_EID_STAT_ACCPTED )
        printf("Allocation status          : Allocation was accepted\n");
    else if (aeid->alloc_status == ALLEOCATE_EID_STAT_REJECTED )
        printf("Allocation status          : Allocation was rejected\n");
    else
        printf("Allocation status          : Reserved\n");

    printf("EID pool size              : %d\n", aeid->eid_pool_size);
    printf("First Endpoint EID         : %d\n", aeid->first_endpoint);

    return;
}

/* Print Get Vendor Defined Message support response */
static void print_get_vmd_support_data(uint8_t *data)
{
    struct get_vmd_support_date *vid = (struct get_vmd_support_date *)data;

    if ( vid->vid_set_selector == MCTP_VID_NO_MORE_CAP ) {
        printf("Vendor ID set selector     : No more capability set\n");
    }
    else {
        printf("Vendor ID set selector     : 0x%02X\n", vid->vid_set_selector );
        if ( vid->vid_data[0] == MCTP_VID_PCIE_VENDOR_ID ) {
            printf("PCIE vendor ID             : 0x%02X%02X\n", vid->vid_data[1], vid->vid_data[2] );
            printf("Number of capability sets  : 0x%02X\n", vid->vid_data[3]);
        }
        else if ( vid->vid_data[0] == MCTP_VID_IANA_VENDOR_ID ) {
            printf("IANA vendor ID             : 0x%02X%02X%02X%0x2\n", vid->vid_data[1], vid->vid_data[2], vid->vid_data[3], vid->vid_data[4]);
            printf("Number of capability sets  : 0x%02X\n", vid->vid_data[5]);
        }
    }

    return;
}

/* Print Set Endpoint ID response */
static void print_set_eid_data(uint8_t *data)
{
    struct set_eid_data *seid = (struct set_eid_data *)data;

    if ( (seid->eid_status & SET_EID_ALOC_STAT_MASK) == SET_EID_ALOC_STAT_NO_POOL )
        printf("EID allocation status      : Devic does not use an EID pool\n");
    else if ( (seid->eid_status & SET_EID_ALOC_STAT_MASK) == SET_EID_ALOC_STAT_REQ_POOL )
        printf("EID allocation status      : Endpoint requires EID pool allocation\n");
    else if ( (seid->eid_status & SET_EID_ALOC_STAT_MASK) == SET_EID_ALOC_STAT_HAS_POOL )
        printf("EID allocation status      : Endpoint uses and EID pool\n");
    else
        printf("EID allocation status      : Reserved\n");

    if ( (seid->eid_status & SET_EID_STATUS_MASK) == SET_EID_STAT_ACCEPTED )
        printf("EID allocation status      : EID assignment accepted\n");
    else if ( (seid->eid_status & SET_EID_STATUS_MASK) == SET_EID_STAT_REJECTED )
        printf("EID allocation status      : EID assignment rejected\n");
    else
        printf("EID allocation status      : Reserved\n");

    printf("Endpoint EID set to        : %d\n", seid->eid_set);
    printf("EID pool size              : %d\n", seid->eid_pool_size);

    return;
}

/* Print Get Endpoint UUID response */
static void print_get_endpoint_uuid_data(uint8_t *data)
{
    struct get_endpoint_uuid_data *uuid_data = (struct get_endpoint_uuid_data *)data;

    printf("Endpoint UUID              : %8.8x-%4.4x-%4.4x-%2.2x%2.2x-",
           uuid_data->time_low, uuid_data->time_mid,
           uuid_data->time_high_ver,
           uuid_data->clk_seq_hi,
           uuid_data->clk_seq_low);
    for ( int i = 0; i < UUID_NODE_SIZE; i++)
        printf("%2.2x ", uuid_data->node[i]);

    printf("\n");

    return;
}

/* Print Get MCTP Message type support response data */
static void print_get_mctp_message_type_data(uint8_t *data)
{

    struct get_mctp_msg_type_data *msg_data = (struct get_mctp_msg_type_data *)data;
    struct msg_type_data  *msgptr = &(msg_data->msgtype);

    printf("Message Type Count         : %d\n", msg_data->msg_type_count);
    printf("MCTP Message Type support  : ");
    for (int i=0; i < msg_data->msg_type_count; i++) {
        switch (msgptr->msg_type)
        {
            case MCTP_MSG_CONTROL:  /* 0x00 */
                printf("MCTP Control, ");
                break;
            case MCTP_MSG_PLDM:     /* 0x01 */
                printf("PLDM, ");
                break;
            case MCTP_MSG_NC_SI:    /* 0x02 */
                printf("NC-SI over MCTP, ");
                break;
            case MCTP_MSG_ETHERNET: /* 0x03 */
                printf("Ethernet over MCTP, ");
                break;
            case MCTP_MSG_NVME:     /* 0x04 */
                printf("NVME over MCTP, ");
                break;
            case MCTP_MSG_VDM_PCIE: /* 0x7E */
                printf("PCIe VDM, ");
                break;
            case MCTP_MSG_VDM_IANA: /* 0x7F */
                printf("IANA VDM, ");
                break;
            default:
                printf("Reserved");
                break;
        } //switch
        msgptr++;
    }
    printf("\n");

    return;
}

/* Print Get MCTP Version response */
static void print_get_mctp_version_data(uint8_t *data)
{
    struct get_mctp_ver_data *ver_data = (struct get_mctp_ver_data *)data;
    struct mctp_ver *ver_ptr = &(ver_data->mctp_ver_entry);

    printf("Number of entries          : %d\n", ver_data->num_of_entry);
    for (int i = 0; i < ver_data->num_of_entry; i++) {
        printf("MCTP Version               : %d.%d",
            (ver_ptr->major_num & MCTP_VER_MAJ_MINO_MASK), (ver_ptr->minor_num & MCTP_VER_MAJ_MINO_MASK));
        if ( ver_ptr->update_ver != MCTP_VER_UPDATE_MASK)
            printf(".%d", ver_ptr->update_ver);
        if ( ver_ptr->alpha_byte != 0 )
            printf(".%d",(ver_ptr->alpha_byte));
        printf("\n");
        ver_ptr += sizeof(struct mctp_ver);
    }

    return;
}

/* Print Get Endpoint ID response */
static void print_get_endpoint_id_data(uint8_t *data)
{
    struct get_endpoint_id_data *id_data = (struct get_endpoint_id_data *)data;

    if ( id_data->endpoint_id == GET_EID_EID_MASK)
        printf("Endpoint ID                : EID not yet assigned\n");
    else
        printf("Endpoint ID                : %d\n", id_data->endpoint_id);

    if ( (id_data->endpoint_type & GET_EID_EP_TYPE_MASK) == GET_EID_EP_TYPE_0 )
        printf("Endpoint Type              : Simple Endpoint\n");
    else if ( (id_data->endpoint_type & GET_EID_EP_TYPE_MASK) == GET_EID_EP_TYPE_1 )
        printf("Endpoint Type              : Bus owner/Bridge\n");
    else
        printf("Endpoint Type              : Reserved\n");

    if ( (id_data->endpoint_type & GET_EID_EID_TYPE_MASK) == GET_EID_DYNAMIC_ED_TYPE_0 )
        printf("Endpoint ID Type           : Dynamic ID\n");
    else
        printf("Endpoint ID Type           : Static ID supported\n");

    return;
}

/* Print Get Routing Table Entires response */
static void print_get_routing_table_entries_data(uint8_t *data)
{
    struct get_routing_table_entries *entries = (struct get_routing_table_entries *)data;
    struct eid_entry *eptr = &entries->eidentry;
    int eid_entry_size  = sizeof(struct eid_entry);

    printf("Entry size = %d\n", eid_entry_size);
    if ( entries->next_entry_handle == ROUTE_ENTRY_NEXT_MASK)
        printf("Next Entry Handle          : No more entries\n");
    else
        printf("Next Entry Handle          : 0x%02x\n", entries->next_entry_handle );

    printf("Number of route entries    : %d\n", entries->num_of_entries);
    for ( int i = 0; i < entries->num_of_entries; i++) {
        printf("\nRouting Entry# - %d\n", (i+1));
        printf("Size of EID range          : %d\n", eptr->size_eid_range );
        printf("Starting EID               : %d\n", eptr->starting_eid );
        printf("Port number                : %d\n", (eptr->entry_type && ROUTE_ENTRY_PORT_MASK) );
        if ( (eptr->entry_type & ROUTE_ENTRY_STATE_MASK) == ROUTE_ENTRY_DYNAMIC )
            printf("Dyname/Static              : Statically configured\n");
        else
            printf("Dynamic/Static             : Dynamically configured\n");

        if ( (eptr->entry_type & ROUTE_ENTRY_TYPE_MASK) == ROUTE_ENTRY_TYPE_0)
            printf("Entry Type                 : Single Endpoint\n");
        else if ( (eptr->entry_type & ROUTE_ENTRY_TYPE_MASK) == ROUTE_ENTRY_TYPE_1 )
            printf("Entry Type                 : EID Range for a Bridge\n");

        else if ( (eptr->entry_type & ROUTE_ENTRY_TYPE_MASK) == ROUTE_ENTRY_TYPE_2 )
            printf("Entry Type                 : Brige device\n");
        else
            printf("Entry Type                 : EID Range for a Bridge\n");

        if (eptr->Phy_binding == PHY_BINDING_PCIE )
            printf("Physical Transport Binding : MCTP over PCIe VDM\n");
        else
            printf("Physical Transport Binding : 0x%02X\n", eptr->Phy_binding);
        if ( eptr->Phy_media == PHY_MEDIA_REV_2_1)
            printf("Physical Media Type        : PCIe revision 2.1 compatible\n");
        else
            printf("Physical Media Type        : 0x%02X\n", eptr->Phy_media);

        printf("Physical Address size      : %d\n", eptr->Phy_address_size);
        printf("Physical Address           : 0x%02X%02X\n", (eptr->Phy_address & ROUTE_ENTRY_PHY_ADDR_MASK),
                                                            ((eptr->Phy_address >> 8) & ROUTE_ENTRY_PHY_ADDR_MASK));
        eptr++;
    }

    return;
}

/* MCTP message response handler */
static void handle_mctp_msg_response(mctp_eid_t src, void *data, void *msg, size_t len,
               bool tag_owner, uint8_t tag, void *msg_binding_private)
{
    struct mctp_ctrl_resp *resp = (struct mctp_ctrl_resp *)msg;
    uint8_t cmd = resp->hdr.command_code;

    switch (cmd)
    {
        case MCTP_CTRL_CMD_SET_ENDPOINT_ID:             /* 0x01 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_set_eid_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_GET_ENDPOINT_ID:             /* 0x02 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_endpoint_id_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_GET_ENDPOINT_UUID:           /* 0x03 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_endpoint_uuid_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_GET_VERSION_SUPPORT:         /* 0x04 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_mctp_version_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_GET_MESSAGE_TYPE_SUPPORT:    /* 0x05 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_mctp_message_type_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_GET_VENDOR_MESSAGE_SUPPORT:  /* 0x06 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_vmd_support_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_RESOLVE_ENDPOINT_ID:         /* 0x07 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_resolve_eid_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_ALLOCATE_ENDPOINT_IDS:       /* 0x08 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_allocate_id_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_GET_ROUTING_TABLE_ENTRIES:   /* 0x0A */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_routing_table_entries_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_PREPARE_ENDPOINT_DISCOVERY:  /* 0x0B */
            printf("MCTP Response data:\n");
            break;
        case MCTP_CTRL_CMD_ENDPOINT_DISCOVERY:          /* 0x0C */
            printf("MCTP Response data:\n");
            break;
        case MCTP_CTRL_CMD_DISCOVERY_NOTIFY:            /* 0x0D used by Bridge device*/
            printf("MCTP Response data:\n");
            break;
        case MCTP_CTRL_CMD_GET_NETWORK_ID:              /* 0x0E */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_get_endpoint_uuid_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_QUERY_HOP:                   /* 0x0F */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_query_hop_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_RESOLVE_UUID:        /* 0x10 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_resolve_uuid_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_QUERY_RATE_LIMIT:            /* 0x11 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_query_rate_limit_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_REQUEST_TX_RATE_LIMIT:       /* 0x12 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_tx_rate_limit_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_UPDATE_RATE_LIMIT:           /* 0x13 */
            printf("MCTP Response data:\n");
            break;
        case MCTP_CTRL_CMD_QUERY_SUPPORTED_INTERFACES:  /* 0x14 */
            printf("MCTP Response data:\n");
            if (resp->completion_code == MCTP_SUCCESS )
                print_query_supported_interfaces_data((uint8_t *)&resp->data);
            break;
        case MCTP_CTRL_CMD_ROUTING_INFO_UPDATE:     /* 0x09 used by Bridge device*/
            printf("\nCommand not Implemented    : 0x%02X\n", cmd);
            break;
        default:
            printf("\nUnknow MCTP Response ...\n");
            return;
    }

    print_completion_code(resp->completion_code);
    dump_payload_data((uint8_t *)&resp->data);
    return;
}

/* Waite and poll for response */
static int wait_for_message(struct mctp_binding_astpcie *astpcie)
{
    int rc;
    time_t endwait;
    int seconds = RESP_WAIT_TIME;

    endwait = time(NULL) + seconds;
    while (time(NULL) < endwait) {
        rc = mctp_astpcie_poll(astpcie, MCTP_RESP_POLL_TIMEOUT);
        if (rc & POLLIN) {
            rc = mctp_astpcie_rx(astpcie);
            assert(rc == MCTP_SUCCESS);
            return MCTP_SUCCESS;
        }
    }
    printf("Endpoint is not responding ...\n");
    return MCTP_FAILURE;
}

/* MCTP messsage request handler */
static int handle_mctp_cmd_request(uint8_t cmd, int route, uint8_t dst_eid , uint8_t *cmd_data)
{
    struct mctp_binding_astpcie *astpcie;
    struct mctp_binding *astpcie_binding;
    struct mctp *mctp;
    struct ctx ctx;

    struct mctp_ctrl_req req;
    struct mctp_astpcie_pkt_private pkt_prv;
    struct mctp_bus *bus;
    int rc;
    uint8_t res_len = 0;

    /* Initialize mctp device */
    mctp = mctp_init();
    assert(mctp);

    astpcie = mctp_astpcie_init();
    assert(astpcie);

    /* Bind the mctp with pcie interface */
    astpcie_binding = mctp_astpcie_core(astpcie);
    assert(astpcie_binding);

//    rc = mctp_register_bus_dynamic_eid(mctp, astpcie_binding);
    rc = mctp_register_bus(mctp, astpcie_binding, BMC_MCTP_EID);
    assert(rc == MCTP_SUCCESS);

    rc = mctp_astpcie_register_default_handler(astpcie);
    assert(rc == MCTP_SUCCESS);

    ctx.mctp = mctp;
    ctx.astpcie_binding = astpcie_binding;
    mctp_binding_set_tx_enabled(ctx.astpcie_binding, true);

    /* Register call back function to recive the response */
    mctp_set_rx_all(mctp, handle_mctp_msg_response, &ctx);

    /* Prepare cmd request */
    memset(&req, 0, sizeof(req));
    req.hdr.ic_msg_type = MCTP_CTRL_HDR_MSG_TYPE;
    req.hdr.rq_dgram_inst |= MCTP_CTRL_HDR_FLAG_REQUEST;
    req.hdr.command_code = cmd;
    pkt_prv.remote_id = MCTP_EID_NULL;
    ctx.bus_owner_eid = BMC_MCTP_EID;
    ctx.discovered = true;
    res_len = (sizeof(struct mctp_ctrl_msg_hdr));

    if (route == 0 )
        pkt_prv.routing = PCIE_ROUTE_TO_RC;
    else if (route == 2)
        pkt_prv.routing = PCIE_ROUTE_BY_ID;
    else
        pkt_prv.routing = PCIE_BROADCAST_FROM_RC;

    switch (cmd)
    {
        case MCTP_CTRL_CMD_SET_ENDPOINT_ID:             /* 0x01 */
            printf("\nMCTP request               : Set Endpoint ID\n");
            for (int i=0; i<MCTP_CTRL_CMD_SET_ENDPOINT_ID_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_SET_ENDPOINT_ID_PLEN;
            break;
        case MCTP_CTRL_CMD_GET_ENDPOINT_ID:             /* 0x02 */
            printf("\nMCTP request               : Get Endpoint ID\n");
            break;
        case MCTP_CTRL_CMD_GET_ENDPOINT_UUID:           /* 0x03 */
            printf("\nMCTP request               : Get Endpoint UUID\n");
            pkt_prv.routing = PCIE_ROUTE_BY_ID;
            break;
        case MCTP_CTRL_CMD_GET_VERSION_SUPPORT:         /* 0x04 */
            printf("\nMCTP request               : Get MCTP Version Support\n");
            for (int i=0; i<MCTP_CTRL_CMD_GET_VERSION_SUPPORT_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_GET_VERSION_SUPPORT_PLEN;
            break;
        case MCTP_CTRL_CMD_GET_MESSAGE_TYPE_SUPPORT:    /* 0x05 */
            printf("\nMCTP request               : Get MCTP Message Type Support\n");
            break;
        case MCTP_CTRL_CMD_GET_VENDOR_MESSAGE_SUPPORT:  /* 0x06 */
            printf("\nMCTP request               : Get MCTP Vendor Defined Message Support\n");
            for (int i=0; i<MCTP_CTRL_CMD_GET_VENDOR_MESSAGE_SUPPORT_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_GET_VENDOR_MESSAGE_SUPPORT_PLEN;
            break;
        case MCTP_CTRL_CMD_RESOLVE_ENDPOINT_ID:         /* 0x07 */
            printf("\nMCTP request               : Resolve Endpoint ID\n");
            for (int i=0; i<MCTP_CTRL_CMD_RESOLVE_ENDPOINT_ID_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_RESOLVE_ENDPOINT_ID_PLEN;
            break;
        case MCTP_CTRL_CMD_ALLOCATE_ENDPOINT_IDS:       /* 0x08 */
            printf("\nMCTP request               : Allocate Endpoint IDs\n");
            for (int i=0; i<MCTP_CTRL_CMD_ALLOCATE_ENDPOINT_IDS_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_ALLOCATE_ENDPOINT_IDS_PLEN;
            break;
        case MCTP_CTRL_CMD_GET_ROUTING_TABLE_ENTRIES:   /* 0x0A */
            printf("\nMCTP request               : Get Routing table entries\n");
            for (int i=0; i<MCTP_CTRL_CMD_GET_ROUTING_TABLE_ENTRIES_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_GET_ROUTING_TABLE_ENTRIES_PLEN;
            break;
        case MCTP_CTRL_CMD_PREPARE_ENDPOINT_DISCOVERY:  /* 0x0B */
            printf("\nMCTP request               : Prepare for Endpoint Discovery\n");
            ctx.discovered = false;
            break;
        case MCTP_CTRL_CMD_ENDPOINT_DISCOVERY:          /* 0x0C */
            printf("\nMCTP request               : Endpoint Discovery\n");
            ctx.discovered = false;
            break;
        case MCTP_CTRL_CMD_DISCOVERY_NOTIFY:            /* 0x0D  used by Bridge device*/
            ctx.discovered = false;
            break;
        case MCTP_CTRL_CMD_GET_NETWORK_ID:              /* 0x0E */
            printf("\nMCTP request               : Get Network ID\n");
            ctx.discovered = true;
            break;
        case MCTP_CTRL_CMD_QUERY_HOP:                   /* 0x0F */
            printf("\nMCTP request               : Query Hop ID\n");
            ctx.discovered = true;
            for (int i=0; i<MCTP_CTRL_CMD_QUERY_HOP_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_QUERY_HOP_PLEN;
            break;
        case MCTP_CTRL_CMD_RESOLVE_UUID:                /* 0x10 */
            printf("\nMCTP request               : Resolve UUID\n");
            ctx.discovered = true;
            for (int i=0; i<MCTP_CTRL_CMD_RESOLVE_UUID_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_RESOLVE_UUID_PLEN;
            break;
        case MCTP_CTRL_CMD_QUERY_RATE_LIMIT:            /* 0x11 */
            printf("\nMCTP request               : Query rate limit\n");
            ctx.discovered = true;
            break;
        case MCTP_CTRL_CMD_REQUEST_TX_RATE_LIMIT:       /* 0x12 */
            printf("\nMCTP request               : Request TX rate limit ID\n");
            ctx.discovered = true;
            for (int i=0; i<MCTP_CTRL_CMD_REQUEST_TX_RATE_LIMIT_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_REQUEST_TX_RATE_LIMIT_PLEN;
            break;
        case MCTP_CTRL_CMD_UPDATE_RATE_LIMIT:           /* 0x13 */
            printf("\nMCTP request               : Update rate limit\n");
            ctx.discovered = true;
            for (int i=0; i<MCTP_CTRL_CMD_UPDATE_RATE_LIMIT_PLEN; i++)
                req.data[i] = cmd_data[i];
            res_len += MCTP_CTRL_CMD_UPDATE_RATE_LIMIT_PLEN;
            break;
        case MCTP_CTRL_CMD_QUERY_SUPPORTED_INTERFACES:  /* 0x14 */
            printf("\nMCTP request               : Query Sopported Interfaces\n");
            ctx.discovered = true;
            break;
        case MCTP_CTRL_CMD_ROUTING_INFO_UPDATE:         /* 0x09 used by Brigde Device */
            printf("\nCommand not Implemented    : 0x%02X\n", cmd);
            return MCTP_FAILURE;
            break;
        default:
            printf("Unknown mctp command: %d", cmd);
            return MCTP_FAILURE;
    }

    //bus = find_bus_for_eid(ctx.mctp, MCTP_EID_NULL);
    /* Send MCTP request packat*/
//    rc= mctp_message_tx_on_bus(ctx.mctp, bus, BMC_MCTP_EID, dst_eid, &req,
    rc= mctp_message_tx(ctx.mctp, dst_eid, &req,
                  res_len, true, 0, &pkt_prv);

    assert(rc == MCTP_SUCCESS);

    /* call to wait for response */
    wait_for_message(astpcie);

    sleep(1);
    mctp_astpcie_free(astpcie);
    mctp_destroy(mctp);

    return rc;
}

/* MCTP command built-in tests */
static int rund_cmd_test(uint8_t dst_eid)
{
    int ret = MCTP_SUCCESS;
    static uint8_t  cmd_data[MCTP_CMD_DATA_BUFF_LEN];
    int route = PCIE_ROUTE_BY_ID;

    printf("\nRunning MCTP commad tests ...\n");
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_ENDPOINT_ID, route, dst_eid, cmd_data);
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_ENDPOINT_UUID, route, dst_eid, cmd_data);

    cmd_data[0] = MCTP_VER_MSG_TYPE_BASE;
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_VERSION_SUPPORT, route, dst_eid, cmd_data);

    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_MESSAGE_TYPE_SUPPORT, route, dst_eid, cmd_data);

    cmd_data[0] = MCTP_VDM_SUPPORT_VID_SELECT;
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_VENDOR_MESSAGE_SUPPORT, route, dst_eid, cmd_data);

    cmd_data[0] = dst_eid;
    cmd_data[1] = MCTP_CTRL_HDR_MSG_TYPE;
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_QUERY_HOP, route, MCTP_MPIO_BRIDGE_EID, cmd_data);

    route = PCIE_ROUTE_TO_RC;
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_RESOLVE_ENDPOINT_ID, route, MCTP_MPIO_BRIDGE_EID, cmd_data);
    ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_NETWORK_ID, route, MCTP_MPIO_BRIDGE_EID, cmd_data);

    return ret;
}

/* MCTP Discovery process */
static int run_mctp_discovery()
{
    int ret = MCTP_SUCCESS;
    static uint8_t  cmd_data[MCTP_CMD_DATA_BUFF_LEN];
    int route = 0;

    printf("\nRunning MCTP discovery ...\n");
    for (int i = 0; i < 3; i++) {
        route = PCIE_BROADCAST_FROM_RC;
        ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_PREPARE_ENDPOINT_DISCOVERY, route, MCTP_EID_NULL, cmd_data);
        if (ret == MCTP_SUCCESS)
            break;
    }
    if ( ret == MCTP_SUCCESS ) {
        route = PCIE_BROADCAST_FROM_RC;
        ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_ENDPOINT_DISCOVERY, route, MCTP_EID_NULL, cmd_data);
    }
    if ( ret == MCTP_SUCCESS ) {
        route = PCIE_ROUTE_BY_ID;
        cmd_data[0] = SET_EID_OP_SET_EID;
        cmd_data[1] = MCTP_MPIO_BRIDGE_EID;
        ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_SET_ENDPOINT_ID, route, MCTP_EID_NULL, cmd_data);
    }
    if ( ret == MCTP_SUCCESS ) {
        route = PCIE_ROUTE_BY_ID;
        cmd_data[0] = ALLOCATE_EIDS_OP_ALLOC_EID;
        cmd_data[1] = ALLOCATE_EIDS_POOL_SIZE;
        cmd_data[2] = ALLOCATE_EIDS_START_EID;
        ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_ALLOCATE_ENDPOINT_IDS, route, MCTP_MPIO_BRIDGE_EID, cmd_data);
    }
    if ( ret == MCTP_SUCCESS ) {
        cmd_data[0] = ROUTE_ENTRY_ENTRY_HANDLE;
        ret = handle_mctp_cmd_request(MCTP_CTRL_CMD_GET_ROUTING_TABLE_ENTRIES, route, MCTP_MPIO_BRIDGE_EID, cmd_data);
    }

    return ret;
}

void usage()
{
    printf("Usage: amd-mctp-cmd-tool [OPTIONS] ...\n");
    printf("-e <eid>   : destination EID\n");
    printf("-c <cmd>   : MCTP cmd and arguments\n");
    printf("-d <data>  : Command data\n");
    printf("-r <data>  : Route code (0=RtoRC, 2=RbyID, 3=BRfromRD\n");
    printf("-D         : run mctp discovery\n");
    printf("-T         : run mctp Command test on eid\n");
    printf("-v         : dump mctp response payload\n");
    printf("-h         : display help\n");
    printf("           : Examples:\n");
    printf("           :  - amd-mctp-tool -D                      : Run the MCTP Discovery to discover Endpoint\n");
    printf("           :  - amd-mctp-tool -e 0x0a -T              : Run the built-in MCTP commands test\n");
    printf("           :  - amd-mctp-tool -e 0x0a -c 0x02 -r 2    : Send 'Get EID' command to destination EID 0x0a\n");
    printf("           :  - amd-mctp-tool -e 0x0a -c 0x02 -r 2 -v : Dump Response payload\n");
}

/* Main function */
int main(int argc, char **argv)
{
    int opt = 0;
    int dst_eid = 0;
    int mctp_cmd = 0;
    int route = -1;
    bool test = false;
    bool discover = false;
    int option_index = 0;
    int ret = MCTP_SUCCESS;
    int data_len;
    static uint8_t  cmd_data[MCTP_CMD_DATA_BUFF_LEN];

    static struct option long_options[] =
    {
        {"dst_eid", required_argument,  0,  'e'},
        {"command", required_argument,  0,  'c'},
        {"data",    required_argument,  0,  'd'},
        {"route",   required_argument,  0,  'r'},
        {"discovery",no_argument,       0,  'D'},
        {"cmdtest",  no_argument,       0,  'T'},
        {"verbose",  no_argument,       0,  'v'},
        {"help",     no_argument,       0,  'h'},
        {0, 0, 0, 0}
    };

    while (opt != -1)
    {
        opt = getopt_long(argc, argv, "e:c:d:r:DThv", long_options, &option_index);
        switch(opt)
        {
            case 'e':
                dst_eid = (int)strtol(optarg, NULL, HEX_BASE);
                if ( dst_eid < MCTP_EID_RESERVED || dst_eid > MCTP_EID_MAX) {
                    printf("Invalid destination EID  '%s'\n", optarg);
                    return MCTP_FAILURE;
                }
                break;
            case 'c':
                 if (optind <= argc) {
                    mctp_cmd = (int)strtol(optarg, NULL, HEX_BASE);
                    if ( mctp_cmd <= MCTP_CTRL_CMD_RESERVED || mctp_cmd > MCTP_CTRL_CMD_MAX) {
                        printf("Invalid MCTP command  '%s'\n", optarg);
                        return MCTP_FAILURE;
                    }
                }
                else {
                    printf("Too many cmd args\n");
                    return MCTP_FAILURE;
                }
                break;
            case 'd':
                if (optind <= argc) {
                    cmd_data[0] = (uint8_t)strtol(optarg, NULL, HEX_BASE);
                    data_len = argc-optind;
                    if ( data_len < MCTP_CMD_DATA_BUFF_LEN ) {
                        for ( int i=1; i <= data_len; i++) {
                            cmd_data[i] = (uint8_t)strtol(argv[optind], NULL, HEX_BASE);
                            optind++;
                        }
                    }
                    else {
                        printf("Too many data args\n");
                        return MCTP_FAILURE;
                    }
                }
                break;
            case 'r':
                route = (int)strtol(optarg, NULL, HEX_BASE);
                if ( (route != PCIE_ROUTE_TO_RC) && (route != PCIE_ROUTE_BY_ID) && (route != PCIE_BROADCAST_FROM_RC) ) {
                    printf("Invalid MCTP route  '%d'\n", route);
                    return MCTP_FAILURE;
                }
                break;
            case 'D': discover = true; break;
            case 'T': test = true; break;
            case 'v': verbose = true; break;
            case 'h': usage(); break;
            default : break;
        } //switch
    }

    /* Run the Discovery */
    if ( discover == true) {
        printf("Running Discovery....\n");
        ret = run_mctp_discovery();
        if ( ret == MCTP_FAILURE )
            printf("MCTP Discovery failed\n");
    }
    /* Run the built-in test cmds */
    else if ( test == true && dst_eid > MCTP_EID_RESERVED ) {
        ret = rund_cmd_test(dst_eid);
        if ( ret == MCTP_FAILURE )
            printf("MCTP command test failed\n");
    }
    /* Run the individual cmds selected by user */
    else if ( mctp_cmd > MCTP_CTRL_CMD_RESERVED  && dst_eid > MCTP_EID_RESERVED & route != -1 ) {
       ret = handle_mctp_cmd_request((uint8_t)mctp_cmd, route, (uint8_t)dst_eid, cmd_data);
        if ( ret == MCTP_FAILURE )
            printf("MCTP command failed\n");
    }

    return ret;
}
