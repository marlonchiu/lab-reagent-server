//  dto 数据传输对象 data transfer object

export class LaboratoryDto {
  readonly id: string;
  readonly name: string;
  readonly description: string;
  readonly location: string;
  readonly contact_person: string;
  readonly contact_phone: string;
  readonly is_active: boolean;
}
