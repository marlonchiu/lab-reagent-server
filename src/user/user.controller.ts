import {
  Controller,
  Get,
  Query,
  Param,
  Put,
  Body,
  Post,
  Delete,
  Patch,
  HttpException,
  HttpStatus,
} from '@nestjs/common';
import { ApiTags } from '@nestjs/swagger';
import { UserService } from './user.service';
import { UserDto } from './dto/user.dto';

@Controller('user')
@ApiTags('用户管理 User')
export class UserController {
  constructor(private readonly userService: UserService) {}

  // 分页查询
  @Get('/page')
  async findAll(
    @Query('keyword') keyword: string,
    @Query('pageNum') pageNum: number,
    @Query('pageSize') pageSize: number,
  ) {
    console.log(keyword, pageNum, pageSize);
    const list = await this.userService.findPage({ keyword, pageNum, pageSize });
    const count = await this.userService.countAll({ keyword });
    return {
      records: list,
      total: count,
    };
  }

  @Get('/list')
  async list(@Query('keyword') keyword: string) {
    const list = await this.userService.findList({ keyword });
    return list;
  }

  // 创建注册
  @Post('/register')
  async register(@Body() dataDto: UserDto) {
    return await this.userService.create(dataDto);
  }

  // 修改
  // @Patch('/update/:id')
  @Put('/update/:id')
  async update(@Param('id') id: string, @Body() dataDto: UserDto) {
    // 数据库返回
    // { "acknowledged": true, "modifiedCount": 1, "upsertedId": null, "upsertedCount": 0, "matchedCount": 1 }
    const data = await this.userService.updateOne(id, dataDto);
    // 修改成功 返回当前数据的id
    if (data.modifiedCount === 1) {
      // return id;
      return this.userService.findById(id);
    } else {
      throw new HttpException('更新失败', HttpStatus.BAD_REQUEST);
    }
  }

  // get 中的 id 要和 @Param('id')  一致
  // 查询 根据 id 查询
  @Get('/getById/:id')
  findOne(@Param('id') id: string) {
    return this.userService.findById(id);
  }

  @Delete('/deleteById/:id')
  deleteById(@Param('id') id: string) {
    return this.userService.deleteOne(id);
  }
}
