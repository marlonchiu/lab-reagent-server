import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { User } from './schemas/user.schema';
import { UserDto } from './dto/user.dto';

@Injectable()
export class UserService {
  constructor(
    // 依赖注入
    @InjectModel(User.name) private readonly userModel: Model<User>,
  ) {}

  async findAll(): Promise<any> {
    return await this.userModel.find();
  }
  // 创建用户
  async create(userDto: UserDto): Promise<any> {
    const createdUser = new this.userModel(userDto);
    return await createdUser.save();
  }

  // 查询单个用户
  async findOne(id: string): Promise<any> {
    return await this.userModel.findById(id);
  }

  // 更新单个用户
  async updateOne(id: string, updateData: UserDto): Promise<any> {
    return await this.userModel.updateOne({ _id: id }, updateData);
  }

  // 删除单个用户
  async deleteOne(id: string): Promise<any> {
    return await this.userModel.findOneAndDelete({ _id: id });
  }
}
