/* SPDX-License-Identifier: Apache-2.0 OR GPL-2.0-or-later */
/* AMD MCTP command test tools
*/

#ifndef _AMD_MCTP_TOOL_H
#define _AMD_MCTP_TOOL_H

#define MCTP_SUCCESS           0
#define MCTP_FAILURE           -1
#define HEX_BASE               16
#define MCTP_VALID_DATA_MIN    0
#define MCTP_VALID_DATA_MAX    0xFF
#define MCTP_RESP_WAIT_TIME    1000
#define MCTP_CMD_DATA_BUFF_LEN 16  /* Cold be changed if need */
#define MCTP_RESP_PAYLOAD_LEN  32

/* Define for MCTP cmds */
#define BMC_MCTP_EID           8
#define MCTP_MPIO_BRIDGE_EID   9
#define MCTP_ENDPOINT_EID      10
#define MCTP_EID_NULL          0
#define RESP_WAIT_TIME         5
#define MCTP_RESP_POLL_TIMEOUT 1000
#define MCTP_EID_RESERVED      8
#define MCTP_EID_MAX           256

/* Define for Get Routing Table Entry */
#define ROUTE_ENTRY_ENTRY_HANDLE    0
#define ROUTE_ENTRY_NEXT_MASK       0xFF
#define ROUTE_ENTRY_PORT_MASK       0x03
#define ROUTE_ENTRY_STATE_MASK      0x20
#define ROUTE_ENTRY_TYPE_MASK       0xC0
#define ROUTE_ENTRY_PHY_ADDR_MASK   0xFF
#define ROUTE_ENTRY_TYPE_0          0x0
#define ROUTE_ENTRY_TYPE_1          0x40
#define ROUTE_ENTRY_TYPE_2          0x80
#define ROUTE_ENTRY_TYPE_3          0xC0
#define ROUTE_ENTRY_DYNAMIC         0
#define PHY_BINDING_PCIE            0x02
#define PHY_MEDIA_REV_2_1           0x0A
#define ROUTE_ENTRY_EID_ENTRY_SIZE      8


/* Define for Set Endpoint ID */
#define SET_EID_OP_SET_EID          0
#define SET_EID_OP_FORCE_EID        1
#define SET_EID_OP_RESET_EID        2
#define SET_EID_OP_SET_DISC_FLG     3
#define SET_EID_ALOC_STAT_MASK      0x03
#define SET_EID_ALOC_STAT_NO_POOL   0
#define SET_EID_ALOC_STAT_REQ_POOL  1
#define SET_EID_ALOC_STAT_HAS_POOL  2

#define SET_EID_STATUS_MASK         0x30
#define SET_EID_STAT_ACCEPTED       0x0
#define SET_EID_STAT_REJECTED       0x10

/* Define for Get Endpoint ID */
#define GET_EID_EID_MASK            0
#define GET_EID_EP_TYPE_MASK        0x30
#define GET_EID_EP_TYPE_0           0x00
#define GET_EID_EP_TYPE_1           0x10
#define GET_EID_EID_TYPE_MASK       0x03
#define GET_EID_DYNAMIC_ED_TYPE_0   0x00
#define GET_EID_EID_TYPE_1          0x10

/* Define for Get Endpoint UUID */
#define UUID_NODE_SIZE         6

/* Define for Get MCTP Version support */
#define MCTP_VER_MSG_TYPE_BASE  0xFF
#define MCTP_VER_MSG_TYPE_CTRL  0x0
#define MCTP_VER_MSG_TYPE_D0241 0x01
#define MCTP_VER_MSG_TYPE_D0261 0x02
#define MCTP_VER_MAJ_MINO_MASK  0x0F
#define MCTP_VER_UPDATE_MASK    0xFF

/* Define for Get Message Type support */
#define MCTP_MSG_TYPE_BASE     0xFF
#define MCTP_MSG_TYPE_SIZE     8
#define MCTP_MSG_CONTROL       0x0
#define MCTP_MSG_PLDM          0x01
#define MCTP_MSG_NC_SI         0x02
#define MCTP_MSG_ETHERNET      0x03
#define MCTP_MSG_NVME          0x04
#define MCTP_MSG_VDM_PCIE      0x7E
#define MCTP_MSG_VDM_IANA      0x7F

/* Define for Get Vendor Defined Message support */
#define MCTP_VDM_SUPPORT_VID_SELECT     0

/* Define for Allocate Endpoint IDs */
#define ALLOCATE_EIDS_OP_ALLOC_EID      0
#define ALLOCATE_EIDS_OP_FORCE_ALLOC    1
#define ALLOCATE_EIDS_OP_GET_ALLOC      2
#define ALLOCATE_EIDS_POOL_SIZE         0xF0 /*256-8 */
#define ALLOCATE_EIDS_START_EID         0x0A
#define ALLEOCATE_EID_STAT_ACCPTED      0
#define ALLEOCATE_EID_STAT_REJECTED     1

/* Define for Get VDM support */
#define MCTP_VID_NO_MORE_CAP    0xFF
#define MCTP_VID_PCIE_VENDOR_ID 0
#define MCTP_VID_IANA_VENDOR_ID 0x01
#define MCTP_VID_DATA_LEN       6

/* Define for Query Hop */
#define MCTP_QUERY_HOP_BASE_UNIT_SIZE   64
#define MCTP_QUERY_HOP_INCREMENT_SIZE   16

/* Response Pad lenght for MCTP cmds */
#define MCTP_CTRL_CMD_UPDATE_RATE_LIMIT_PLEN            8
#define MCTP_CTRL_CMD_REQUEST_TX_RATE_LIMIT_PLEN        8
#define MCTP_CTRL_CMD_RESOLVE_UUID_PLEN                 17
#define MCTP_CTRL_CMD_QUERY_HOP_PLEN                    2
#define MCTP_CTRL_CMD_GET_ROUTING_TABLE_ENTRIES_PLEN    1
#define MCTP_CTRL_CMD_ALLOCATE_ENDPOINT_IDS_PLEN        3
#define MCTP_CTRL_CMD_RESOLVE_ENDPOINT_ID_PLEN          1
#define MCTP_CTRL_CMD_GET_VENDOR_MESSAGE_SUPPORT_PLEN   1
#define MCTP_CTRL_CMD_GET_VERSION_SUPPORT_PLEN          1
#define MCTP_CTRL_CMD_SET_ENDPOINT_ID_PLEN              2

/* MCTP control request struct */
struct mctp_ctrl_req {
    struct mctp_ctrl_msg_hdr hdr;
    uint8_t data[MCTP_BTU];
};

/* MCTP control response struct */
struct mctp_ctrl_resp {
    struct mctp_ctrl_msg_hdr hdr;
    uint8_t completion_code;
    uint8_t data[MCTP_BTU];
} resp;

/* MCTP context struct */
struct ctx {
    struct mctp *mctp;
    struct mctp_binding *astpcie_binding;
    mctp_eid_t eid;
    bool discovered;
    uint16_t bus_owner_bdf;
    mctp_eid_t bus_owner_eid;
};

/* Structure for Resolve UUID response */
struct resolve_uuid_data {
    uint8_t bridge_eid;
    uint16_t phy_addres;
};

/* Structure for Query Supported Interfaces response */
struct eid_interface {
    uint8_t intf_type;
    uint8_t intf_eid;
};
struct query_supported_interfaces_Res_data {
    uint8_t interface_count;
    struct eid_interface eid_intf;
};

/* Structure for Update Rate limit request */
struct update_rate_limit_Req_data {
    uint32_t tx_max_burst_size;
    uint32_t max_tx_rate_limit;
};

/* Structure for TX Rate limit request */
struct tx_rate_limit_Req_data {
    uint32_t tx_max_burst_size;
    uint32_t max_tx_rate_limit;
};

/* Structure for Request TX Rate limit response */
struct tx_rate_limit_Res_data {
    uint32_t curr_tx_burst_size;
    uint32_t curr_tx_rate_limit;
};

/* Structure for Query Rate limit response */
struct query_rate_limit_data {
    uint32_t recv_buff_size;
    uint32_t max_recv_rate_limit;
    uint32_t max_support_limit;
    uint32_t min_support_limit;
    uint32_t max_burst_size;
    uint32_t curr_bust_set;
    uint32_t curr_rate_limit;
    uint8_t tx_rate_limt_cap;
};

/* Structure for Query Hop response */
struct query_hop_data {
    uint8_t eid_next_bridge;
    uint8_t msg_type;
    uint16_t in_trans_unit_size;
    uint16_t out_trans_unit_size;
};

/* Structure for Resolve Endpoint ID response */
struct resolve_eid_data {
    uint8_t bridge_eid;
    uint16_t phy_addr;
};

/* Structure for Get Routing Table Entry response */
struct eid_entry {
    uint8_t size_eid_range;
    uint8_t starting_eid;
    uint8_t entry_type;
    uint8_t Phy_binding;
    uint8_t Phy_media;
    uint8_t Phy_address_size;
    uint16_t Phy_address;
};
struct get_routing_table_entries {
    uint8_t next_entry_handle;
    uint8_t num_of_entries;
    struct eid_entry eidentry;
};

/* Structure for Get Endpoint ID respons */
struct get_endpoint_id_data {
    uint8_t endpoint_id;
    uint8_t endpoint_type;
};

/* Structure for Get MCTP Version support response */
struct mctp_ver {
    uint8_t major_num;
    uint8_t minor_num;
    uint8_t update_ver;
    uint8_t alpha_byte;
};
struct get_mctp_ver_data {
    uint8_t num_of_entry;
    struct mctp_ver mctp_ver_entry;
};

/* Structure for Get Endpoint UUID response */
struct get_endpoint_uuid_data {
    uint32_t time_low;
    uint16_t time_mid;
    uint16_t time_high_ver;
    uint8_t clk_seq_hi;
    uint8_t clk_seq_low;
    uint8_t node[UUID_NODE_SIZE];
};

/* Structure for Get MCTP Message Type support response */
struct msg_type_data {
    uint8_t msg_type;
};

struct get_mctp_msg_type_data {
    uint8_t msg_type_count;
    struct msg_type_data msgtype;
//    uint8_t msg_type_list[MCTP_MSG_TYPE_SIZE];
};

/* Structure for Set EID response */
struct set_eid_data {
    uint8_t eid_status;
    uint8_t eid_set;
    uint8_t eid_pool_size;
};

/* Structure for Allocate ID response */
struct alloc_eid_data {
    uint8_t alloc_status;
    uint8_t eid_pool_size;
    uint8_t first_endpoint;
};

#define MCTP_VID_DATA_LEN       6
#define MCTP_VID_NO_MORE_CAP    0xFF
#define MCTP_VID_PCIE_VENDOR_ID 0
#define MCTP_VID_IANA_VENDOR_ID 0x01

/* Structure for Get VDM support response */
struct get_vmd_support_date {
    uint8_t vid_set_selector;
    uint8_t vid_data[MCTP_VID_DATA_LEN];
};

#endif