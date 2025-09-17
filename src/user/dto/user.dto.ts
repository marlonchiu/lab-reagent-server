//  dto 数据传输对象 data transfer object

export class UserDto {
  readonly _id: string;
  readonly username: string;
  readonly password: string;
  readonly nickname: string;
  readonly realname: string;
  readonly email: string;
  readonly phone: string;
  readonly laboratory_id: string;
  readonly role: string;
  readonly avatar: string;
  readonly is_active: boolean;
}
