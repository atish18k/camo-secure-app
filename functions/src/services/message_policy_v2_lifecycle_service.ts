import {CamoCanonicalMessagePolicyV2, CamoMessagePolicyStoreV2} from "../domain/message_policy_v2_types";
import {CamoMessageValidityV1} from "../domain/message_policy_types";
function id(v:string,n:string){const x=v.trim();if(!x||x.includes("/"))throw new Error(`invalid_${n}`);return x;}
export class CamoMessagePolicyV2LifecycleService {
  constructor(private readonly store:CamoMessagePolicyStoreV2,private readonly clock:()=>Date=()=>new Date()){}
  async reserve(input:Readonly<{messageId:string;pairId:string;senderUserId:string;senderDeviceId:string;operationId:string;validity:CamoMessageValidityV1}>):Promise<CamoCanonicalMessagePolicyV2>{
    const now=this.clock();if(!Number.isFinite(now.getTime()))throw new Error("invalid_server_clock");
    const createdAt=now.toISOString();const policy:CamoCanonicalMessagePolicyV2=Object.freeze({schemaVersion:2,messageId:id(input.messageId,"message_id"),pairId:id(input.pairId,"pair_id"),senderUserId:id(input.senderUserId,"user_id"),senderDeviceId:id(input.senderDeviceId,"device_id"),operationId:id(input.operationId,"operation_id"),state:"pending",validity:input.validity,oneTimeView:false,createdAt,updatedAt:createdAt,pendingExpiresAt:new Date(now.getTime()+60000).toISOString()});
    if(!await this.store.reserveIfAbsent(policy))throw new Error("message_policy_v2_reservation_rejected");return policy;
  }
  async activate(messageId:string,authorizationId:string,signingKeyId:string){await this.move(messageId,"pending","active",authorizationId,signingKeyId);}
  async block(messageId:string,reason:string){await this.move(messageId,"pending","blocked",undefined,undefined,reason);}
  async consume(messageId:string){await this.move(messageId,"active","consumed");}
  private async move(messageId:string,expectedState:"pending"|"active",nextState:"active"|"blocked"|"consumed",authorizationId?:string,signingKeyId?:string,failureReasonCode?:string){const at=this.clock().toISOString();if(!await this.store.transitionIfState({messageId:id(messageId,"message_id"),expectedState,nextState,transitionedAt:at,authorizationId,signingKeyId,failureReasonCode}))throw new Error("message_policy_v2_transition_rejected");}
}
