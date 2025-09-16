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
}

export const UserSchema = SchemaFactory.createForClass(User);
