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

  async findAllList({ keyword = '', pageNum = 1, pageSize = 10 }): Promise<any> {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.nickname = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.userModel
      .find(whereOpt)
      .sort({ _id: 1 }) // _id倒序
      .skip((pageNum - 1) * pageSize) // 跳过
      .limit(pageSize) // 限制
      .exec();
  }

  async countAll({ keyword = '' }) {
    const whereOpt: any = {};

    if (keyword) {
      const reg = new RegExp(keyword, 'i');
      whereOpt.nickname = { $regex: reg }; // 模糊搜索 'abc'
    }

    return await this.userModel.countDocuments(whereOpt);
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
