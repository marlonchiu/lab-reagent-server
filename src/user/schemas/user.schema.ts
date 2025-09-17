import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { HydratedDocument } from 'mongoose';

export type UserDocument = HydratedDocument<User>;

@Schema({
  timestamps: true, // 记录时间戳 crateAt & updateAt
})
export class User {
  @Prop({ required: true, unique: true })
  username: string;

  @Prop({ required: true })
  password: string;

  @Prop()
  nickname: string;

  @Prop()
  realname: string;

  @Prop()
  email: string;

  @Prop()
  phone: string;

  @Prop()
  laboratory_id: string;

  @Prop()
  role: string;

  @Prop()
  avatar: string;

  @Prop({ default: true })
  is_active: boolean;
}

export const UserSchema = SchemaFactory.createForClass(User);
